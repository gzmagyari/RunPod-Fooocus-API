![github-header](https://github.com/qodeindustries/Quinn-AI/assets/66263283/bf8149b2-cdc3-4a59-96fb-1d272221ef70)
![Static Badge](https://img.shields.io/badge/API_version-0.4.1.0-blue) ![Static Badge](https://img.shields.io/badge/Fooocus_version-2.4.1-blue) ![Static Badge](https://img.shields.io/badge/API_coverage-100%25-vividgreen) ![Static Badge](https://img.shields.io/badge/API_tests-passed-vividgreen)

[Fooocus-API](https://github.com/mrhan1993/Fooocus-API) RunPod serverless worker implementation

---

The repository consists of two branches:
[NetworkVolume](https://github.com/davefojtik/RunPod-Fooocus-API/tree/NetworkVolume) and [Standalone](https://github.com/davefojtik/RunPod-Fooocus-API/tree/Standalone)

The **NetworkVolume** expects you to install and prepare your own instance on the RunPod network volume, or to use our `3wad/runpod-fooocus-api:0.4.1.0-networksetup` to do so. This is ideal if you want to change models, loras or other contents on the fly, let your users upload them, or persist generated image files right on the server. The downside of this solution is slower starts because everything has to be loaded over the data centre's network. See [network-guide](https://github.com/davefojtik/RunPod-Fooocus-API/blob/NetworkVolume/docs/network-guide.md) for step-by-step instructions.

The **Standalone** branch is a ready-to-use docker image with all the files and models already baked and installed into it. You can still customize it to use your own content, but it can't be changed without rebuilding and redeploying the image. This is ideal if you want the fastest, cheapest possible endpoint for long-term usage without the need for frequent changes in its contents. See [standalone-guide](https://github.com/davefojtik/RunPod-Fooocus-API/blob/Standalone/docs/standalone-guide.md) or simply use `3wad/runpod-fooocus-api:0.4.1.0-standalone` as the image for a quick deploy with the default Juggernaut V8 on your RunPod serverless endpoint.

All prebuilt images can be found here: https://hub.docker.com/r/3wad/runpod-fooocus-api

## How to send requests

[request_examples.js](https://github.com/davefojtik/RunPod-Fooocus-API/blob/NetworkVolume/docs/request_examples.js) contain example payloads for all endpoints on your serverless worker, regardless of the branch. But don't hesitate to ask if you need more help.

## Contributors Welcomed

Feel free to make pull requests, fixes, improvements and suggestions to the code. Any cooperation on keeping this repo up-to-date and free of bugs is highly welcomed.

## Updates

We're not always on the latest version automatically, as there can be breaking changes or major bugs. The updates are being made only after thorough tests by our community of Discord users generating images with the AI agent using this repo as its tool. And only if we see that the new version performs better and more stable.

---

> [!NOTE]
> _This repo is in no way affiliated with RunPod Inc. All logos and names are owned by the authors. This is an unofficial community implementation_
