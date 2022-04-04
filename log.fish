function debug
    echo -e "[YPM:DEBUG] $argv" >&2
end

function info
    echo -e "\x1b[1m[YPM:INFO] $argv\x1b[0m" >&2
end

function warn
    echo -e "\x1b[1;33m[YPM:WARN] $argv\x1b[0m" >&2
end

function error
    echo -e "\x1b[1;31m[YPM:ERROR] $argv\x1b[0m" >&2
end

function panic
    error "[FAULT]" $argv
    exit 1
end
