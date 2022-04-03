#!/usr/bin/env fish

# 載入 logging library
. ./log.fish

# 載入與安全相關的 library
. ./safevar.fish

# 要求指定的環境變數
# safevar YPM_PORTABLE_FILE_PATH

# consts
set -g YPM_DIST_DIR dist

# 暫存目錄
set -g tmp_dirs

function create_dist -d "建立 dist 資料夾"
    rm -r $YPM_DIST_DIR
    mkdir $YPM_DIST_DIR
end

function extract_ypm -d "取得 YPM 的軟體目錄"
    # 取得 YPM 檔案的路徑   
    set ypm_file_path $argv[1]

    # 建立暫存目錄
    set tmpdir (mktemp -d)

    # 將目前的暫存目錄加進去 $tmp_dir 列表裡面
    set -g tmp_dirs $tmp_dirs $tmpdir

    # 將 YPM 免安裝檔複製到暫存目錄
    exe_nonfailable_cmd cp $ypm_file_path $tmpdir/ypm.exe

    # 進入暫存目錄
    pushd $tmpdir
    
    # 呼叫 7z 解壓縮最外層的執行檔
    exe_nonfailable_cmd 7z x ypm.exe -y -oypm_i

    # 將 app-64.7z 拷貝到暫存目錄外層，稱之為 app.7z
    exe_nonfailable_cmd cp ypm_i/\$PLUGINSDIR/app-64.7z app.7z

    # 呼叫 7z 解壓縮 app.7z
    exe_nonfailable_cmd 7z x app.7z -y -oypm_app

    popd

    # 將 ypm_app 複製到目前目錄的 dist 資料夾
    cp -r $tmpdir/ypm_app $YPM_DIST_DIR/app

    # 將 $ypm_app_dir 設定為 ypm_app 所在的路徑
    set -g ypm_app_dir $YPM_DIST_DIR/app
end

function create_scripts -d "建立 YPM 啟動指令碼"
    echo ':: workaround of #1145
"%~dp0"\app\YesPlayMusic.exe' > $ypm_app_dir/../start.bat

    echo '@echo off
if "%1" == "h" goto begin
mshta vbscript:createobject("wscript.shell").run("""%~nx0"" h",0)(window.close)&&exit
:begin
"%~dp0"\app\YesPlayMusic.exe' > $ypm_app_dir/../start_silently.bat
end

create_dist
extract_ypm YesPlayMusic-0.4.4.exe
create_scripts

# GC: 清理用完的目錄
for dir in $tmp_dirs
    info Cleanup: $dir
    rm -r $dir
end
