sudo apt install docker-buildx-plugin
DOCKER_BUILDKIT=1 docker build --network=host -t led-badge:latest .
