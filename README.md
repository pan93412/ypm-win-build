# ypm-win-build

組建 YPM for Windows 的啟動器，來繞過 [#1145](https://github.com/qier222/YesPlayMusic/issues/1145) 的問題。

## Prerequisites

- 目前僅在 macOS 測試過
  - Linux 可能需要將 `_hash` 裡面的 `shasum -a 256` 更改為 `sha256sum`
  - 未測試 Windows 平台，大概是不支援
- 需要安裝 `p7zip` 和 `curl`

## Usage

從遠端下載：

    fish build.sh https://github.com/qier222/YesPlayMusic/releases/download/v0.4.4-1/YesPlayMusic-0.4.4-1.exe

使用本地檔案：

    set -gx YPM_SRC_FILE /path/to/YPM/portable.exe
    fish build.sh

## License

GPL-3.0-or-later

## Authors

- pan93412, 2022.
