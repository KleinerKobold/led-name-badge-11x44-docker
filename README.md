# LED Badge Controller

This project allows you to build a Docker image for controlling LED name badges via HID devices.

---

## 📦 Build the Image

```bash
make build
```

---

## 🔍 Check Device Detection

```bash
make detect
```

If no device is detected, set the HIDRAW device manually, for example:

```bash
HIDRAW=/dev/hidraw6
```

---

## ✉️ Send Data to the Badge

### Send Text

```bash
# Basic usage
make send TEXT="Victor"

# Specify device manually
make send HIDRAW=/dev/hidraw6 TEXT="Oliver"

# Optional parameters: SPEED, MODE, BRIGHTNESS
make send TEXT="Welcome" SPEED=7 MODE=0 BRIGHTNESS=75
```

### Send PNG Image

```bash
make image IMG=gfx/fablabnbg_logo_44x11.png
```

### List Connected Devices

```bash
make list
```

---

## 🐚 Interactive Shell in the Container

```bash
make shell
```

---

## 📝 Notes

- Mapping with `--device=$(HIDRAW)` is fully sufficient for **hidapi**.  
  **No privileged flags are required.**
- If you have multiple badges connected, override the `HIDRAW` variable for each command.
- If auto-detection using `udevadm` does not work on your system, set the `HIDRAW` device manually.

---

## ▶️ Direct Usage with Docker

You can also run the tool directly inside the container:

```bash
docker run --rm --network=none   --device=/dev/hidraw6   -v "$PWD":/work   -w /work   led-badge:latest   python -m lednamebadge -M hidapi -s 5 -m 0 -B 75 "Oliver Staudt"
```

After sending data, **unplug and reconnect** the device.
