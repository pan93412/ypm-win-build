# ypm-win-build

組建 YPM for Windows 的啟動器，來繞過 [#1145](https://github.com/qier222/YesPlayMusic/issues/1145) 的問題。

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
