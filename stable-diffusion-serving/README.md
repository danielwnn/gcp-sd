# Stable Diffusion - Real-time Serving

## Introduction

THis article shows how to containerize stable diffusion using Huggingface's diffusers library into a serving container using [fastapi](https://fastapi.tiangolo.com/) which can be served with Vertex AI prediction.

Features:
- Text to image.
- Image to image.
- Inpainting.
- Uses xformers and attention slicing and fp16 to reduce GPU memory.

## Setup

1. Cone repo if you haven't. Navigate to the `serving-stable-diffusion` folder.
1. Build container. Change the `project-id` to yours. Right now `model_name` only supports models hosted in Huggingface. In the future models from other sources will be supported.

    ```bash
    PROJECT_ID=<project-id>
    docker build -t gcr.io/$PROJECT_ID/serving-sd:latest --build-arg model_name=runwayml/stable-diffusion-v1-5 --build-arg use_xformers=1 --build-arg model_revision=fp16 .
    ```

1. Run container. You need [NVIDIA docker](https://github.com/NVIDIA/nvidia-docker) and a GPU.

    ```bash
    docker run -p 80:8080 --gpus all -e AIP_HEALTH_ROUTE=/health -e AIP_HTTP_PORT=8080 -e AIP_PREDICT_ROUTE=/predict gcr.io/jfacevedo-demos/serving-sd:latest
    ```

1. Test the container locally.

    ```bash
    python test_container.py > results.jsonl
    ```

    `results.jsonl` will contain the response with the generated images.

1. Validate prediction. This will create an `output` folder with the generated images from the previous step.

    ```bash
    python validate_response.py --response-json response.jsonl
    ```

## Deploy in Vertex AI.

You'll need to enable Vertex AI and have authenticated with a service account that has the Vertex AI admin or editor role.

1. Push the image

    ```bash
    gcloud auth configure-docker
    docker push gcr.io/$PROJECT_ID/serving-sd:latest
    ```

1. Deploy in Vertex AI prediction.

    ```bash
    python ../gcp_deploy.py --image-uri gcr.io/$PROJECT_ID/serving-sd:latest --model-name stable-diffusion --endpoint-name stable-diffusion-endpoint --endpoint-deployed-name stable-diffusion-deployed-name
    ```

1. The last command will display the endpoint name, it should look like `projects/611558971877/locations/us-central1/endpoints/3386579376433790976`: 

    Test the endpoint using the endpoint name.

    ```bash
    python generate_request_vertex.py --endpoint-name projects/611558971877/locations/us-central1/endpoints/3386579376433790976
    ```