#!/usr/bin/env bash
# 极致性能+健壮性版 Cava 输出脚本

CONFIG="$HOME/.config/cava/config"

# 启动 cava 并保存 PID
cava -p "$CONFIG" 2>/dev/null &
CAVA_PID=$!

cleanup() {
    kill "$CAVA_PID" 2>/dev/null
    wait "$CAVA_PID" 2>/dev/null
    exit 0
}
trap cleanup SIGINT SIGTERM SIGPIPE

# 预生成字符映射表
# 预生成字符映射表
symbols=(▁ ▂ ▃ ▄ ▅ ▆ ▇ █)
declare -a char_map
for i in {0..100}; do
    level=$(( (i * 8 + 50) / 100 ))
    ((level>7)) && level=7
    ((level<0)) && level=0
    char_map[i]=${symbols[level]}
done


# 使用进程替换，避免管道子shell问题
while IFS=';' read -ra values; do
    [[ ${#values[@]} -eq 0 ]] && continue

    local_out=()
    for ((i=0; i<16 && i<${#values[@]}; i++)); do
        num="${values[i]//[[:space:]]/}"
        if [[ "$num" =~ ^[0-9]+$ && $num -le 100 ]]; then
            local_out+=("${char_map[num]}")
        else
            local_out+=(" ")
        fi
    done

    printf '{"text": "%s"}\n' "$(IFS=; echo "${local_out[*]}")"
done < <(cava -p "$CONFIG" 2>/dev/null)

cleanup
# 确保清理