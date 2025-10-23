#!/bin/bash
# 极致性能版cava脚本

CAVA_CMD="/home/verfox/.config/waybar/scripts/cava_config"


trap 'pkill -f "cava -p $CAVA_CMD" 2>/dev/null; exit 0' SIGPIPE SIGTERM SIGINT

# 预计算所有可能的映射（0-100到字符的映射）
# 直接映射0-8数字到字符
declare -a char_map=(
    [0]=" "    # 0 -> 空格
    [1]="▁"    # 1 -> ▁
    [2]="▂"    # 2 -> ▂
    [3]="▃"    # 3 -> ▃
    [4]="▄"    # 4 -> ▄
    [5]="▅"    # 5 -> ▅
    [6]="▆"    # 6 -> ▆
    [7]="▇"    # 7 -> ▇
    [8]="█"    # 8 -> █
)

# 检查cava进程是否在运行，如果已经在运行则退出
if pgrep -f "cava -p $CAVA_CMD" > /dev/null; then
    echo "cava进程已经在运行，退出脚本" >&2
    exit 0
fi

# 使用命名管道来避免管道断开问题
pipe_file="/tmp/cava_pipe_$$"
mkfifo "$pipe_file"

# 启动cava进程，将输出重定向到命名管道
cava -p $CAVA_CMD 2>/dev/null > "$pipe_file" &
cava_pid=$!

# 设置后台进程退出时清理命名管道
trap 'rm -f "$pipe_file"; pkill -P $cava_pid 2>/dev/null; exit 0' EXIT

# 从命名管道读取数据，处理管道断开的情况
while IFS=';' read -a values < "$pipe_file" 2>/dev/null; do
    [[ ${#values[@]} -eq 0 ]] && continue
    
    result=""
    for ((i=0; i<16 && i<${#values[@]}; i++)); do
        num="${values[i]//[[:space:]]/}"
        if [[ "$num" =~ ^[0-9]+$ ]] && ((num <= 100)); then
            result+="${char_map[num]:- }"
        else
            result+=" "
        fi
    done
    
    # 检查管道是否仍然有效，如果无效则退出
    if ! printf '{"text": "%s"}\n' "$result" 2>/dev/null; then
        break
    fi
done

# 清理cava进程
pkill -f "cava -p $CAVA_CMD" 2>/dev/null