#!/usr/bin/env fish

# 載入 logging library
. ./log.fish

# 載入與安全相關的 library
. ./safevar.fish

# 載入清除暫存目錄的 library
. ./tmpgc.fish

# -> $YPM_SRC_FILE
function get_ypm_src -d "取得 YPM 的原始檔案"
    # 取得 src 檔的路徑
    set src_http_address $argv[1]
    
    # 建立暫存目錄
    set tmpdir (exe_nonfailable_cmd mktemp -d)
    
    # 將目前的暫存目錄加進去 $tmp_dir 列表裡面
    set -g TMP_DIRS $TMP_DIRS $tmpdir
    
    # 擷取檔案名稱
    set ypm_filename (basename $src_http_address)
    
    # 將 $YPM_SRC_FILE 設定為預計放置 ypm.exe 的路徑
    set -g YPM_SRC_FILE {$tmpdir}/{$ypm_filename}
    
    info "正在下載 $src_http_address (-> $YPM_SRC_FILE)⋯⋯"

    # 下載 YPM 執行檔
    exe_nonfailable_cmd curl -Lo "$YPM_SRC_FILE" "$src_http_address"
end

# -> $YPM_DIST_DIR
function create_dist -d "建立 dist 資料夾"
    info 正在建立 dist 資料夾⋯⋯
    set -g YPM_DIST_DIR dist
    
    rm -r $YPM_DIST_DIR
    exe_nonfailable_cmd mkdir $YPM_DIST_DIR
end

# -> $YPM_APP_DIR
function extract_ypm -d "解壓縮 YPM 免安裝包，擷取其軟體目錄"
    info 正在解壓縮 YPM 免安裝包⋯⋯

    # 取得輸出路徑
    set dist_path $argv[1]

    # 取得 YPM 檔案的路徑   
    set ypm_file_path $argv[2]

    # 建立暫存目錄
    set tmpdir (exe_nonfailable_cmd mktemp -d)

    # 將目前的暫存目錄加進去 $tmp_dir 列表裡面
    set -g TMP_DIRS $TMP_DIRS $tmpdir

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
    
    # 將 $YPM_APP_DIR 設定為 ypm_app 預期的路徑
    set -g YPM_APP_DIR {$dist_path}"/app"

    # 將 ypm_app 複製到目前目錄的 dist 資料夾
    exe_nonfailable_cmd cp -r $tmpdir/ypm_app $YPM_APP_DIR
end

function create_scripts -d "建立 YPM 啟動指令碼"
    info 正在建立 YPM 啟動指令碼⋯⋯

    # 取得 YPM 檔案的路徑   
    set ypm_dist_dir $argv[1]

    echo ':: workaround of #1145
"%~dp0"\app\YesPlayMusic.exe' > $ypm_dist_dir/start.bat

    echo '@echo off
if "%1" == "h" goto begin
mshta vbscript:createobject("wscript.shell").run("""%~nx0"" h",0)(window.close)&&exit
:begin
"%~dp0"\app\YesPlayMusic.exe' > $ypm_dist_dir/start_silently.bat
end

function _hash
    shasum -a 256 $argv | awk '{print $1}'
end

function _get_hash_txt
    set filepath $argv[1]
    set filename (basename $filepath)

    echo $filename 的 SHA-256 hash： (_hash $filepath)
end

function create_readme -d "產生 README 檔案"
    info 正在產生 README 檔案⋯⋯
    set ypm_dist_dir $argv[1]
    set ypm_src $argv[2]
    set ypm_app_dir $argv[3]

    set readme_filepath $ypm_dist_dir/README.txt

    echo "本壓縮包是從 "(basename $ypm_src)" 安裝包組建的，修正 #1145 問題的版本。" > $readme_filepath
    echo "" >> $readme_filepath

    echo (_get_hash_txt $ypm_app_dir/YesPlayMusic.exe) >> $readme_filepath
    echo (_get_hash_txt $ypm_dist_dir/start.bat) >> $readme_filepath
    echo (_get_hash_txt $ypm_dist_dir/start_silently.bat) >> $readme_filepath
end

function compress_artifact -d "壓縮建立完成的檔案"
    info 正在壓縮建立完成的檔案⋯⋯
    set ypm_dist_dir $argv[1]
    set ypm_portable_file_path $argv[2]
    set ypm_build_name (basename $ypm_portable_file_path ".exe")

    pushd $ypm_dist_dir
    set filename {$ypm_build_name}"_WINPATCH.zip"

    exe_nonfailable_cmd 7z a $filename .

    popd
end

# 取得 YPM 的來源（Windows 免安裝檔案）檔案
if test -n "$argv[1]"
    info 有指定 YPM 下載路徑，正在下載⋯⋯
    get_ypm_src $argv[1] # -> $YPM_SRC_FILE
else if test -n "$YPM_SRC_FILE"
    info 已經有指定 YPM 來源檔案，不需要下載⋯⋯
else
    panic 未知 YPM 來源檔案的位置。
end

create_dist
extract_ypm $YPM_DIST_DIR $YPM_SRC_FILE
create_scripts $YPM_DIST_DIR
create_readme $YPM_DIST_DIR $YPM_SRC_FILE $YPM_APP_DIR
compress_artifact $YPM_DIST_DIR $YPM_SRC_FILE

info "檔案全部都在 dist 資料夾。"

tmpgc
