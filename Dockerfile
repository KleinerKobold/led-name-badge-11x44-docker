FROM python:3.11-slim

# Systemlibs und Build-Tools
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      git ca-certificates \
      libhidapi-hidraw0 libhidapi-libusb0 libusb-1.0-0 \
      libhidapi-dev build-essential pkg-config \
 && rm -rf /var/lib/apt/lists/*

# Python Pakete
RUN pip install --no-cache-dir pyhidapi hidapi pyusb pillow

# hidraw Bibliothek so verlinken, dass pyhidapi sie auch unter dem libusb-Namen findet
RUN sh -lc '\
  HRAW=$(ls /usr/lib/*/libhidapi-hidraw.so.* | head -n1); \
  ln -sf "$HRAW" /usr/local/lib/libhidapi-hidraw.so.0; \
  ln -sf "$HRAW" /usr/local/lib/libhidapi-libusb.so.0; \
  ldconfig'

# Code holen
WORKDIR /app
RUN git clone https://github.com/jnweiger/led-name-badge-ls32.git .
ENV PYTHONPATH=/app

# Arbeitsverzeichnis
WORKDIR /work
