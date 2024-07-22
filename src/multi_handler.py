# Native
import shutil
import os
import time
import requests
import re
import base64
import json
import subprocess
import threading

# Dependencies
import runpod
from requests.adapters import HTTPAdapter, Retry

# Configurations
API_INSTANCES = [
    {"port": 8887, "baseurl": "http://127.0.0.1:8888", "busy": False},
    {"port": 4447, "baseurl": "http://127.0.0.1:4448", "busy": False},
    # Add more instances as needed
]

# Session setup for retries
sd_session = requests.Session()
retries = Retry(total=10, backoff_factor=0.1, status_forcelist=[502, 503, 504])
sd_session.mount('http://', HTTPAdapter(max_retries=retries))

# ---------------------------------------------------------------------------- #
#                               Functions                                      #
# ---------------------------------------------------------------------------- #

def start_api_instance(instance):
    """Start a Fooocus API instance on the given port."""
    port = instance["port"]
    output_path = f"/temp/fooocus_output{port}"
    temp_path = f"/temp/fooocus_temp{port}"
    cache_path = f"/temp/cache{port}"

    command = [
        "python", "/launch.py",
        "--disable-in-browser",
        "--always-gpu",
        "--disable-offload-from-vram",
        "--listen", "0.0.0.0",
        "--port", str(port),
        "--output-path", output_path,
        "--temp-path", temp_path,
        "--cache-path", cache_path
    ]

    subprocess.Popen(command)
    wait_for_service(instance["baseurl"])

def wait_for_service(url):
    """Check if the service is ready to receive requests."""
    while True:
        try:
            requests.get(url)
            return
        except requests.exceptions.RequestException:
            print(f"Service at {url} not ready yet. Retrying...")
        except Exception as err:
            print("Error: ", err)
        time.sleep(0.2)

def run_inference(instance, params):
    """Run inference using the specified API instance."""
    config = {
        "api": {
            "home": ("GET", "/"),
            "docs": ("GET", "/docs/"),
            "generate": ("POST", "/v1/engine/generate/"),
            "control": ("POST", "/v1/engine/control/"),
            "query_tasks": ("GET", "/tasks"),
            "task_by_id": ("GET", "/tasks/{task_id}"),
            "models": ("GET", "/v1/engines/all-models"),
            "styles": ("GET", "/v1/engines/styles"),
            "describe": ("POST", "/v1/tools/describe-image"),
        },
        "timeout": 300
    }
    
    api_name = params["api_name"]
    if api_name in config["api"]:
        api_config = config["api"][api_name]
    else:
        raise Exception(f"Method '{api_name}' not yet implemented")

    api_verb = api_config[0]
    api_path = api_config[1].format(task_id=params.get("task_id", ""))
    response = {}

    def process_img(value):
        if re.search(r'https?:\/\/\S+', value) is not None:
            return requests.get(value).content
        elif re.search(r'^[A-Za-z0-9+/]+[=]{0,2}$', value) is not None and value != "None":
            return base64.b64decode(value)
        else:
            return value

    # Process image inputs
    input_imgs = {
        'input_image': None,
        'inpaint_input_image': None,
        'inpaint_mask_image_upload': None,
        'uov_input_image': None,
        'controlnet_image': None
    }
    
    for key in input_imgs.keys():
        if key in params:
            try:
                input_imgs[key] = process_img(params[key])
            except Exception as e:
                error_message = str(e)
                print("Image conversion task failed: ", error_message)
                return {"error": error_message}
    
    # Convert the processed binary image back to url-safe-base64
    for key, value in input_imgs.items():
        if value is not None:
            params[key] = base64.b64encode(value).decode('utf-8')

    if api_verb == "GET":
        response = sd_session.get(
            url=f'{instance["baseurl"]}{api_path}', 
            timeout=config["timeout"]
        )

    if api_verb == "POST":
        response = sd_session.post(
            url=f'{instance["baseurl"]}{api_path}',
            json=params,
            timeout=config["timeout"]
        )

    # --- Return the API response to the RunPod ---
    content_type = response.headers.get('Content-Type', '')
    if 'application/json' in content_type:
        return response.json()
    else:
        return response.text

def preview_stream(jsn, event, instance):
    """Stream previews for async processing."""
    try:
        job_finished = False
        api_name = event["input"].get("api_name")
        headers = event["input"].get('preview_headers', {})
        if api_name in ["generate"]:
            if headers != {}: headers = json.loads(headers)
        while job_finished is False:
            preview = sd_session.get(f'{instance["baseurl"]}/v1/generation/query-job', params={"job_id": jsn["job_id"], "require_step_preview": "true"}).json()
            requests.post(event["input"]["preview_url"], json=preview, headers=headers)
            if preview["job_stage"] == "SUCCESS" or preview["job_stage"] == "ERROR":
                job_finished = True
                return
            time.sleep(int(event["input"].get('preview_interval', 1)))
    except Exception as e:
        error_message = str(e)
        print("async preview task failed: ", error_message)
        return {"error": error_message}

def clear_output_directories():
    """Clear output directories dynamically based on instances."""
    try:
        print("Clearing outputs...")
        for instance in API_INSTANCES:
            output_path = f"/temp/fooocus_output{instance['port']}"
            if os.path.exists(output_path):
                shutil.rmtree(output_path)
            os.makedirs(output_path)
    except Exception as e:
        error_message = str(e)
        print("clear outputs task failed: ", error_message)
        return {"error": error_message}

def get_free_instance():
    """Get a free API instance."""
    for instance in API_INSTANCES:
        if not instance["busy"]:
            instance["busy"] = True
            return instance
    return None

def get_random_instance():
    """Get a random API instance."""
    return API_INSTANCES[0]

def release_instance(instance):
    """Release the API instance."""
    instance["busy"] = False

# ---------------------------------------------------------------------------- #
#                                RunPod Handler                                #
# ---------------------------------------------------------------------------- #
def handler(event):
    """This is the handler function that will be called by the serverless."""
    clear_output = event["input"].get("clear_output", True)
    if clear_output is True or str(clear_output).lower() == "true":
        clear_output_directories()

    # Get a free instance
    instance = get_free_instance()
    if instance is None:
        instance = get_random_instance()

    try:
        # Main process
        json_response = run_inference(instance, event["input"])
        
        # Check for async preview streaming
        if 'preview_url' in event["input"] and 'job_step_preview' in json_response:
            preview_stream(json_response, event, instance)
        
        return json_response
    finally:
        # Release the instance
        release_instance(instance)

def start_remaining_instances():
    """Start the remaining API instances."""
    for instance in API_INSTANCES[1:]:  # Skip the first instance as it is already started
        threading.Thread(target=start_api_instance, args=(instance,)).start()

if __name__ == "__main__":
    if len(API_INSTANCES) > 0:
        # Start the first API instance and wait for it to be ready
        start_api_instance(API_INSTANCES[0])

        # Start the remaining API instances in the background
        if len(API_INSTANCES) > 1:
            threading.Thread(target=start_remaining_instances).start()

    print("Fooocus API Service is ready. Starting RunPod...")

    runpod.serverless.start({"handler": handler})
