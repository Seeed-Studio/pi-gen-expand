# pi-gen-expand

This project aims to automatically generate Raspberry Pi systems adapted for multiple devices. It allows users to specify devices and configurations in the workflow, and then automatically generates the corresponding Raspberry Pi system.

## Image List

| Name                  |   username & password   | enable-ssh |                 stage-list                  |      date      |
|-----------------------|-------------------------|------------|---------------------------------------------|----------------|
| raspberrypi-arm64     | pi & raspberry          | 1          | stage0 stage1 stage2 stage3 stage4          | [2025-11-03](https://github.com/Seeed-Studio/pi-gen-expand/releases/download/v1.1.5/Raspbian-raspberrypi-arm64.tar.xz)|
| reTerminal-arm64      | pi & raspberry          | 1          | stage0 stage1 stage2 stage3 stage4 stage4a  | [2025-11-03](https://github.com/Seeed-Studio/pi-gen-expand/releases/download/v1.1.5/Raspbian-reTerminal-arm64.tar.xz)|
| reComputer-R100x-arm64 | recomputer & 12345678   | 1          | stage0 stage1 stage2 stage3 stage4 stage4a  | [2025-11-03](https://github.com/Seeed-Studio/pi-gen-expand/releases/download/v1.1.5/Raspbian-reComputer-R100x-arm64.tar.xz)|
| reComputer-R110x-arm64 | recomputer & 12345678   | 1          | stage0 stage1 stage2 stage3 stage4 stage4a  | [2025-11-03](https://github.com/Seeed-Studio/pi-gen-expand/releases/download/v1.1.5/Raspbian-reComputer-R110x-arm64.tar.xz)|
| reComputer-AI-box-arm64 | recomputer & 12345678   | 1          | stage0 stage1 stage2 stage3 stage4 stage4a  | [2025-11-03](https://github.com/Seeed-Studio/pi-gen-expand/releases/download/v1.1.5/Raspbian-reComputer-AI-box-arm64.tar.xz)|
| reTerminal-DM-arm64   | pi & raspberry          | 1          | stage0 stage1 stage2 stage3 stage4 stage4a  | [2025-11-03](https://github.com/Seeed-Studio/pi-gen-expand/releases/download/v1.1.5/Raspbian-reTerminal-DM-arm64.tar.xz)|
| reComputer-AI-box-cm5-arm64 | recomputer & 12345678   | 1          | stage0 stage1 stage2 stage3 stage4 stage4a  | [2025-08-19](https://github.com/Seeed-Studio/pi-gen-expand/releases/download/v1.1.4/Raspbian-reComputer-AI-box-cm5-arm64.tar.xz)|
| reComputer-R2x-arm64  | recomputer & 12345678   | 1          | stage0 stage1 stage2 stage3 stage4 stage4a  | [2025-08-19](https://github.com/Seeed-Studio/pi-gen-expand/releases/download/v1.1.4/Raspbian-reComputer-R2x-arm64.tar.xz)|
| reComputer-AI-box-cm5-bookworm-arm64 | recomputer & 12345678   | 1          | stage0 stage1 stage2 stage3 stage4 stage4a  | [2025-11-03](https://github.com/Seeed-Studio/pi-gen-expand/releases/download/v1.1.5/Raspbian-reComputer-AI-box-cm5-bookworm-arm64.tar.xz) |

