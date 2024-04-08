![Static Badge](https://img.shields.io/badge/API_version-0.3.33-blue) ![Static Badge](https://img.shields.io/badge/API_coverage-100%25-vividgreen) ![Static Badge](https://img.shields.io/badge/API_tests-passed-vividgreen) ![Static Badge](https://img.shields.io/badge/Fooocus_version-2.3.0-lightgrey)

# RunPod-Fooocus-API

This repository consists of two branches:
[NetworkVolume](https://github.com/davefojtik/RunPod-Fooocus-API/tree/NetworkVolume) and [Standalone](https://github.com/davefojtik/RunPod-Fooocus-API/tree/Standalone)  
  
![image](https://github.com/davefojtik/RunPod-Fooocus-API/assets/66263283/88d74dd7-2dcd-44a8-af01-f1ce29bfb713)


The **NetworkVolume** expects you to install and prepare your own `Fooocus-API v0.3.33` instance on the RunPod network volume, or to use our `3wad/runpod-fooocus-api:0.3.33-networksetup` image. This is ideal if you want to change models, loras or other contents on the fly. The downside of this solution is slower starts, especially when the endpoint is not used frequently. See [network-guide](https://github.com/davefojtik/RunPod-Fooocus-API/blob/NetworkVolume/docs/network-guide.md) for step-by-step instructions.

The **Standalone** branch is a ready-to-use docker image with all the files and models already baked and installed into it. You can still customize it to use your own content, but it can't be changed without rebuilding and redeploying the image. This is ideal if you want the fastest, cheapest possible endpoint for long-term usage without the need for frequent changes of models or loras. See [standalone-guide](https://github.com/davefojtik/RunPod-Fooocus-API/blob/Standalone/docs/standalone-guide.md) or simply use `3WaD/RunPod-Fooocus-API:v0.3.33-standalone` as the image for a quick deploy with the default Juggernaut V8 on your RunPod serverless endpoint.

## How to send requests
[request_examples.js](https://github.com/davefojtik/RunPod-Fooocus-API/blob/NetworkVolume/docs/request_examples.js) contain example payloads for all endpoints on your serverless worker, regardless of the branch. But don't hesitate to ask if you need more help.

## Contributors Welcomed
Feel free to make pull requests, fixes, improvements and suggestions to the code. I can spend only limited time on this as it's only a side tool project for an AI Agent. So any cooperation will help manage this repo better.

## Updates
The version of compatible Fooocus-API is always stated at the top of this readme. We're not always on the latest version automatically, as there can be breaking changes. The updates are being made only after thorough tests on our community discord bot, and only if we see that the new version performs better or solves some problems.
