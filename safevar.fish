function safevar
    set var_name $argv[1]

    if not set -q $var_name
        . log.fish
        panic 需要指定 $var_name！
    end
end

function exe_nonfailable_cmd
    if not $argv
        . log.fish
        panic $argv 執行失敗。
    end
end
