# pi-gen-expand

This project aims to automatically generate Raspberry Pi systems adapted for multiple devices. It allows users to specify devices and configurations in the workflow, and then automatically generates the corresponding Raspberry Pi system.

## Image List

| Name                  |   username & password   | enable-ssh |                 stage-list                  |      date      |
|-----------------------|-------------------------|------------|---------------------------------------------|----------------|
| raspberrypi-arm64     | pi & raspberry          | 1          | stage0 stage1 stage2 stage3 stage4          | [2026-01-09](https://seeedstudio88-my.sharepoint.com/personal/baozhu_zuo_seeedstudio88_onmicrosoft_com/_layouts/15/download.aspx?share=IQDt-6fjb1XLTa_DoFivfeq0AQvS649oG5x9LjIWfVAbTws)|
| reTerminal-arm64      | pi & raspberry          | 1          | stage0 stage1 stage2 stage3 stage4 stage4a  | [2026-01-09](https://seeedstudio88-my.sharepoint.com/personal/baozhu_zuo_seeedstudio88_onmicrosoft_com/_layouts/15/download.aspx?share=IQCevzQ2Dx4gSIBshDTjBXRBATZlWmXE89-ZEQ4OWpz__GU)|
| reComputer-R100x-arm64 | recomputer & 12345678   | 1          | stage0 stage1 stage2 stage3 stage4 stage4a  | [2026-01-09](https://seeedstudio88-my.sharepoint.com/personal/baozhu_zuo_seeedstudio88_onmicrosoft_com/_layouts/15/download.aspx?share=IQB5utqGJyvUQLkEkK6ZtWYGATyy3fFDoQQ8Na91uMDMuVQ)|
| reComputer-R110x-arm64 | recomputer & 12345678   | 1          | stage0 stage1 stage2 stage3 stage4 stage4a  | [2026-01-09](https://seeedstudio88-my.sharepoint.com/personal/baozhu_zuo_seeedstudio88_onmicrosoft_com/_layouts/15/download.aspx?share=IQCXPEo3jMyJSJ7i5ssSzucmAXfHdPrIeb0Iy9IL19lSGGU)|
| reComputer-AI-box-arm64 | recomputer & 12345678   | 1          | stage0 stage1 stage2 stage3 stage4 stage4a  | [2026-01-09](https://seeedstudio88-my.sharepoint.com/personal/baozhu_zuo_seeedstudio88_onmicrosoft_com/_layouts/15/download.aspx?share=IQDY7xzhC3D3QajXNZ1VUsgMAbwGYYMYsStDg8wzQUcpVn8)|
| reTerminal-DM-arm64   | pi & raspberry          | 1          | stage0 stage1 stage2 stage3 stage4 stage4a  | [2026-01-09](https://seeedstudio88-my.sharepoint.com/personal/baozhu_zuo_seeedstudio88_onmicrosoft_com/_layouts/15/download.aspx?share=IQDqsJSB74QBQYLCbVNyD33LAbvoa_veehvxyCDQXnsJ924)|
| reComputer-AI-box-cm5-arm64 | recomputer & 12345678   | 1          | stage0 stage1 stage2 stage3 stage4 stage4a  | [2026-01-09](https://seeedstudio88-my.sharepoint.com/personal/baozhu_zuo_seeedstudio88_onmicrosoft_com/_layouts/15/download.aspx?share=IQBJuMqqFaWbTrcU5APKEjYKATLeh10MOpUYd4azdokmTZo)|
| reComputer-R2x-arm64  | recomputer & 12345678   | 1          | stage0 stage1 stage2 stage3 stage4 stage4a  | [2025-08-19](https://github.com/Seeed-Studio/pi-gen-expand/releases/download/v1.1.4/Raspbian-reComputer-R2x-arm64.tar.xz)|
| reComputer-AI-box-cm5-bookworm-arm64 | recomputer & 12345678   | 1          | stage0 stage1 stage2 stage3 stage4 stage4a  | [2025-11-05](https://seeedstudio88-my.sharepoint.com/personal/baozhu_zuo_seeedstudio88_onmicrosoft_com/_layouts/15/download.aspx?share=EZS_yFIp9jdJu2QLFH8TMj8B6RqJVyk7aGsXIMOs1RR9gQ)|
| reComputer-R2x-bookworm-arm64 | recomputer & 12345678   | 1          | stage0 stage1 stage2 stage3 stage4 stage4a  | [2025-11-05](https://seeedstudio88-my.sharepoint.com/personal/baozhu_zuo_seeedstudio88_onmicrosoft_com/_layouts/15/download.aspx?share=EbaEf6WI6a5KicBNrsZWwCABrhh94JyXgzEad8NIXR3Xjw) |
| reComputer-R22-bookworm-arm64 | recomputer & 12345678   | 1          | stage0 stage1 stage2 stage3 stage4 stage4a  | [2025-11-05](https://seeedstudio88-my.sharepoint.com/personal/baozhu_zuo_seeedstudio88_onmicrosoft_com/_layouts/15/download.aspx?share=EYOjt8-GR11PtTAkk7vZ8CQBatfAX0Mu_A4MjdycKaecFw) |
| reComputer-R22-arm64  | recomputer & 12345678   | 1          | stage0 stage1 stage2 stage3 stage4 stage4a  | [2026-01-09](https://seeedstudio88-my.sharepoint.com/personal/baozhu_zuo_seeedstudio88_onmicrosoft_com/_layouts/15/download.aspx?share=IQCrEgxB3GNQTbvQb4JHbUr1AclzIOpGPR--P6pTduMc5J4) |

