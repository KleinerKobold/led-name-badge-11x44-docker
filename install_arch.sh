sudo pacman -S docker-buildx
# Sicherstellen, dass der CLI Plugin Pfad passt
mkdir -p ~/.docker/cli-plugins
[ -x /usr/lib/docker/cli-plugins/docker-buildx ] && \
  ln -sf /usr/lib/docker/cli-plugins/docker-buildx ~/.docker/cli-plugins/docker-buildx

docker buildx version
DOCKER_BUILDKIT=1 docker build --network=host -t led-badge:latest .
