# Hardware inventory and upstream references

**Manufacturer:** M5Stack Tab5 C145/K145.
Official documentation: https://docs.m5stack.com/en/core/Tab5

| Item | Manufacturer specification |
|---|---|
| Main processor | ESP32-P4 RISC-V |
| Wireless companion | ESP32-C6-MINI-1U; **2.4 GHz** Wi-Fi 6 |
| Flash / PSRAM | 16 MB / 32 MB |
| Screen | 5-inch 1280×720 MIPI-DSI touchscreen |
| Storage | microSD slot |
| Computer connection | USB Type-C, USB 2.0 OTG |
| Other | Audio, camera, USB-A host, RS-485, GPIO expansion |

## IMPORTANT: display revisions
Earlier Tab5 production uses **ILI9881C (display) + GT911 (touch)**. Starting October 14, 2025, M5Stack changed to **ST7123 integrated display/touch**, with documentation also listing **ST7121** on some units. Read the device's rear sticker and identify the exact hardware **before** compiling drivers; pin compatible M5Unified/M5GFX versions after proving them on the actual board. Do not assume every Tab5 accepts one frozen binary.

## Radio limitation
The built-in ESP32-C6 is a **2.4 GHz** radio; it cannot scan 5 GHz access points by itself. The ESP32-P4 depends on the ESP32-C6 host stack to expose Wi-Fi functionality. Driver support for each feature is an engineering verification gate, not a documented product promise.

## Upstream firmware/toolchain references
- M5Stack Tab5 overview, download mode, Arduino and PlatformIO example: https://docs.m5stack.com/en/core/Tab5
- M5Unified: https://github.com/M5Stack/M5Unified
- M5GFX: https://github.com/M5Stack/M5GFX
- Espressif ESP-IDF: https://docs.espressif.com/projects/esp-idf/en/stable/esp32p4/
- esptool: https://docs.espressif.com/projects/esptool/en/latest/esp32p4/
- PIO Arduino platform example is included in M5Stack docs. Its branch and library versions are **unverified for this device**; do not freeze toolchain versions based on a guess.

## First toolchain source baseline
The feature branch `feature/touch-ui-preflight-v0` pins official M5Stack documented PlatformIO baseline `54.03.21` and minimum compatible M5Unified `0.2.23` / M5GFX `0.2.30`. The Git refs were verified to exist; actual PlatformIO compile and local Windows USB flashing have **not yet been verified**.

## Physical inventory — fill at first laptop session
| Measurement | Actual value |
|---|---|
| Rear sticker / LCD driver revision | NOT RECORDED — required before flashing |
| Windows PowerShell version | NOT RECORDED |
| Connected COM port (if enumerated) | COM3 — ESP32-P4 v1.3, confirmed via esptool 5.6.0 on 2026-11-13 |
| USB VID/PID | VID_303A / PID_1001 (no unique device ID stored) |
| Existing firmware / partition layout | Detected SPI flash 16 MB (manufacturer 0x46, device 0x4018); existing partition map/protection unknown |
| Existing flash backup SHA-256 | NOT RECORDED |
| microSD backup directory and hash manifest | NOT RECORDED |
| Verified toolchain and library commits | NOT RECORDED |

Do not commit real Wi-Fi passwords, tokens, private backups, home public IP, or scan reports to this public repository.
