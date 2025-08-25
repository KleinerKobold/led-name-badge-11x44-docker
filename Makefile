# Makefile
IMAGE ?= led-badge
TAG ?= latest
VENDOR ?= 0416
PRODUCT ?= 5020
NET ?= none
ENVVARS ?= -e LD_LIBRARY_PATH=/usr/local/lib:/usr/lib:/usr/lib/x86_64-linux-gnu
# HIDRAW bitte beim Aufruf setzen, z. B. HIDRAW=/dev/hidraw6
DOCKER_RUN = docker run --rm --network=$(NET) $(ENVVARS) \
	--device=$(HIDRAW) -v $(PWD):/work -w /work $(IMAGE):$(TAG)

# Automatische Erkennung des passenden /dev/hidrawX nach Vendor und Product
# Du kannst HIDRAW auch manuell setzen, z. B. "make send HIDRAW=/dev/hidraw6 TEXT='Hallo'"
HIDRAW ?= $(shell \
  for d in /dev/hidraw*; do \
    if udevadm info -q property -n $$d 2>/dev/null | grep -q "ID_VENDOR_ID=$(VENDOR)"; then \
      if udevadm info -q property -n $$d 2>/dev/null | grep -q "ID_MODEL_ID=$(PRODUCT)"; then \
        echo $$d; break; \
      fi; \
    fi; \
  done)

.DEFAULT_GOAL := help

help:
	@echo "Targets:"
	@echo "  make build                     Buildet das Docker Image"
	@echo "  make detect                    Zeigt das erkannte HIDRAW Device"
	@echo "  make shell [HIDRAW=/dev/hidrawX]  Startet eine Shell im Container mit Device Mapping"
	@echo "  make list  [HIDRAW=...]        Listet erkannte Badges"
	@echo "  make send  TEXT='Victor' [SPEED=5 MODE=0 BRIGHTNESS=75 HIDRAW=...]"
	@echo "  make image IMG=pfad/44x11.png [MODE=5 HIDRAW=...]"
	@echo ""
	@echo "Variablen:"
	@echo "  HIDRAW   Pfad zum hidraw Device. Autoerkennung versucht $(VENDOR):$(PRODUCT)"
	@echo "  VENDOR   USB Vendor ID, default $(VENDOR)"
	@echo "  PRODUCT  USB Product ID, default $(PRODUCT)"

build:
	DOCKER_BUILDKIT=1 docker build --network=host -t led-badge:latest .

test:
	docker run --rm --network=none led-badge:latest python -c "import pyhidapi as ph; ph.hid_init(); print('pyhidapi ok')"


detect:
	@echo "Detected HIDRAW: $(HIDRAW)"
	@test -n "$(HIDRAW)" || (echo "Hinweis: Kein passendes hidraw Device gefunden. Stecke das Badge neu ein oder setze HIDRAW manuell." && exit 1)

shell: detect
	$(DOCKER_RUN) bash

list: detect
	$(DOCKER_RUN) python -m lednamebadge -M hidapi -l x

send:
	@test -n "$(HIDRAW)" || (echo "Bitte HIDRAW setzen, z. B. HIDRAW=/dev/hidraw6"; exit 1)
	@test -n "$(TEXT)" || (echo "Usage: make send HIDRAW=/dev/hidraw6 TEXT='Oliver' [SPEED=5 MODE=0 BRIGHTNESS=75]"; exit 1)
	$(DOCKER_RUN) python -m lednamebadge -M hidapi \
		-s $(if $(SPEED),$(SPEED),5) \
		-m $(if $(MODE),$(MODE),0) \
		-B $(if $(BRIGHTNESS),$(BRIGHTNESS),75) \
		"$(TEXT)"

image: detect
	@test -n "$(IMG)" || (echo "Usage: make image IMG=pfad/44x11.png [MODE=5 HIDRAW=...]" && exit 1)
	$(DOCKER_RUN) python -m lednamebadge -M hidapi \
	  -m $(if $(MODE),$(MODE),5) \
	  :$(IMG):

