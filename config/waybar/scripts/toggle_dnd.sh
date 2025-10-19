#!/bin/bash

# 设置状态文件路径
STATE_FILE="/tmp/mako_dnd_state"

# 检查状态文件是否存在，如果不存在则创建并设置为关闭状态
if [ ! -f "$STATE_FILE" ]; then
    echo "0" > "$STATE_FILE"
fi

# 读取当前状态
current_state=$(cat "$STATE_FILE")

# 切换状态
if [ "$current_state" -eq 1 ]; then
    # 如果已启用勿扰模式，则禁用它
    new_state=0
    echo "0" > "$STATE_FILE"
else
    # 如果未启用勿扰模式，则启用它
    new_state=1
    echo "1" > "$STATE_FILE"
fi

# 根据新状态显示相应的图标和提示
if [ "$new_state" -eq 1 ]; then
    echo '{"text":"", "tooltip":"点击关闭勿扰模式", "class":"dnd"}'
else
    echo '{"text":"", "tooltip":"点击开启勿扰模式", "class":"active"}'
fi

# 如果makoctl可用，则执行相应的命令
if command -v makoctl &> /dev/null; then
    if [ "$new_state" -eq 1 ]; then
        makoctl mode -a do-not-disturb
    else
        makoctl mode -r do-not-disturb
    fi
fi