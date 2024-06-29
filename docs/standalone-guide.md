## How to use standalone image
- [**Create RunPod serverless endpoint:**](https://www.runpod.io/console/serverless) use `3wad/runpod-fooocus-api:0.4.1.0-standalone`
- Other settings are your choice, but I personally found that using 4090/L4 GPUs + Flashboot is the most cost-effective one.
- That's it! See the [request_examples](https://github.com/davefojtik/RunPod-Fooocus-API/blob/Standalone/docs/request_examples.js) for how to make requests to this endpoint from your app.

## How to customize standalone image
To modify default settings and model, see [default.json](https://github.com/davefojtik/RunPod-Fooocus-API/blob/Standalone/src/default.json)  
To modify which models and files are being baked into the image, see [Dockerfile](https://github.com/davefojtik/RunPod-Fooocus-API/blob/Standalone/Dockerfile)

After customizing your image, build and upload it to the Docker Hub so you can use it on your serverless endpoint.