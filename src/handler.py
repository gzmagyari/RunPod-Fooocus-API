# Native
import shutil
import os
import time
import requests
import re
import base64
import json
# Dependencies
import runpod
from requests.adapters import HTTPAdapter, Retry

sd_session = requests.Session()
retries = Retry(total=10, backoff_factor=0.1, status_forcelist=[502, 503, 504])
sd_session.mount('http://', HTTPAdapter(max_retries=retries))

# ---------------------------------------------------------------------------- #
#                               Functions                                      #
# ---------------------------------------------------------------------------- #

def wait_for_service(url):
    # Check if the service is ready to receive requests
    while True:
        try:
            requests.get(url)
            return
        except requests.exceptions.RequestException:
            print("Service not ready yet. Retrying...")
        except Exception as err:
            print("Error: ", err)
        time.sleep(0.2)

def run_inference(params):
    config = {
        "baseurl": "http://127.0.0.1:8888",
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
            url=f'{config["baseurl"]}{api_path}', 
            timeout=config["timeout"]
        )

    if api_verb == "POST":
        response = sd_session.post(
            url=f'{config["baseurl"]}{api_path}',
            json=params,
            timeout=config["timeout"]
        )

    # --- Return the API response to the RunPod ---
    content_type = response.headers.get('Content-Type', '')
    if 'application/json' in content_type:
        return response.json()
    else:
        return response.text

def preview_stream(jsn, event):
    try:
        job_finished = False
        api_name = event["input"].get("api_name")
        headers = event["input"].get('preview_headers', {})
        if api_name in ["generate"]:
            if headers != {}: headers = json.loads(headers)
        while job_finished is False:
            preview = sd_session.get('http://127.0.0.1:8888/v1/generation/query-job', params={"job_id": jsn["job_id"], "require_step_preview": "true"}).json()
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
    try:
        print("Clearing outputs...")
        output_dirs = ['/workspace/outputs/files', '/workspace/outputs']
        for dir_path in output_dirs:
            if os.path.exists(dir_path):
                shutil.rmtree(dir_path)
            os.makedirs(dir_path)
    except Exception as e:
        error_message = str(e)
        print("clear outputs task failed: ", error_message)
        return {"error": error_message}

# ---------------------------------------------------------------------------- #
#                                RunPod Handler                                #
# ---------------------------------------------------------------------------- #
def handler(event):
    ''' This is the handler function that will be called by the serverless. '''
    # Check for clear outputs option (defaults to True, send "clear_output":false in your payload to keep the images stored on the network volume.)
    # Also works on standalone but does not make much sense since the workers are stateless.
    clear_output = event["input"].get("clear_output", True)
    if clear_output is True or str(clear_output).lower() == "true":
        clear_output_directories()

    # Main process
    json_response = run_inference(event["input"])
    
    # Check for async preview streaming (turn on by adding "async_process":true in your generation params and include custom "preview_url":"https://your.app/endpoint")
    if 'preview_url' in event["input"] and 'job_step_preview' in json_response:
        preview_stream(json_response, event)
    
    # Return the output that you want to be returned like pre-signed URLs to output artifacts
    return json_response

if __name__ == "__main__":
    wait_for_service(url='http://127.0.0.1:8888/v1/engine/generate/')

    print("Fooocus API Service is ready. Starting RunPod...")

    runpod.serverless.start({"handler": handler})
