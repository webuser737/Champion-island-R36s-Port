# Champion-island-R36s-Port
The long awaited port of champion island for the R36S!

A standalone offline port of **Google Doodle Champion Island Games** for the **R36S** handheld running **ArkOS / ArkOS4Clone**.

The game runs locally using a bundled **QtWebEngine/Chromium browser** and a local HTTP server, with controller support adapted for the R36S.

## Features

* 🎮 R36S controller support
* ⬆️ D-pad movement
* 🅰️ A button → interact
* 🅱️ B button → unused
* ▶️ START → Escape / cancel
* SELECT → unused
* START + SELECT → exit back to EmulationStation
* 🌐 Completely offline
* 🖥️ Fullscreen `eglfs` display
* 🎨 Hardware-accelerated rendering using the R36S Mali GPU
* 💾 Persistent browser/game storage
* 🔊 Original game audio and assets

## Target Hardware

Tested on:

* **R36S**
* Rockchip RK3326
* Mali-G31 MP2
* 1 GB RAM
* ArkOS / ArkOS4Clone
* 720×720 display

## Installation

Copy the following folder to the R36S SD card:

```text
/roms/ports/championisland/
```

Then copy the launcher to:

```text
/roms/ports/Champion Island.sh
```

The launcher should be available from **EmulationStation → Ports**.

## Directory Structure

```text
championisland/
├── app/
│   └── browser.py
├── game/
│   ├── index.html
│   ├── kitsune20.js
│   └── ...
├── lib/
├── locales/
├── resources/
├── QtWebEngineProcess
└── Champion Island.sh
```

## How It Works

The port uses a local Python HTTP server to serve the game:

```text
http://127.0.0.1:8765/
```

`browser.py` launches the bundled QtWebEngine browser in fullscreen `eglfs` mode.

The launcher configures the R36S graphics environment and starts the browser from the physical console TTY so Qt can use DRM/KMS.

## Controller Mapping

The R36S Gamepad API layout used by this port is:

| R36S Control   | Game Action              |
| -------------- | ------------------------ |
| D-pad Up       | Arrow Up                 |
| D-pad Down     | Arrow Down               |
| D-pad Left     | Arrow Left               |
| D-pad Right    | Arrow Right              |
| A              | Space / Interact         |
| B              | Unused                   |
| START          | Escape / Cancel          |
| SELECT         | Unused                   |
| START + SELECT | Exit to EmulationStation |

## Graphics

The port is designed to use the R36S Mali GPU rather than software rendering.

The launcher uses:

```bash
QT_QPA_PLATFORM=eglfs
```

and loads the R36S Mali GBM libraries before the system graphics libraries.

> Performance may vary depending on the ArkOS build, Mali driver version, and QtWebEngine configuration.

## Credits

Original game:

**Google — Doodle Champion Island Games**

Browser/acceleration work:

**chr15m / web-game-console**

R36S porting and controller integration:

**techygames**

## Disclaimer

This project is an unofficial fan-made port and is not affiliated with or endorsed by Google.

The original Google Doodle Champion Island Games assets and code remain the property of their respective owners.

Please obtain the original game files legally and respect their licenses and copyrights.

## Status

🚧 **Work in progress**

Current goals include improving rendering performance and achieving smoother gameplay on the R36S.

## License

The custom launcher and porting code in this repository may be released under the license specified below.

The original Google Champion Island game assets are **not** licensed by this project and should not be treated as being under the repository's license.
