# 儲存暫存目錄的變數
#
# 若要將自己的目錄加進去暫存目錄中，
# 只需輸入： `set -g TMP_DIRS $TMP_DIRS 你的目錄`
set -g TMP_DIRS

function tmpgc -d "清空所有暫存目錄"
    for dir in $TMP_DIRS
        info Cleanup: $dir
        rm -r $dir
    end
end
