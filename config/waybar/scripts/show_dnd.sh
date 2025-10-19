#!/bin/bash

# 设置状态文件路径
STATE_FILE="/tmp/mako_dnd_state"

# 检查状态文件是否存在，如果不存在则创建并设置为关闭状态
if [ ! -f "$STATE_FILE" ]; then
    echo "0" > "$STATE_FILE"
fi

# 读取当前状态
current_state=$(cat "$STATE_FILE")

# 根据当前状态显示相应的图标和提示
if [ "$current_state" -eq 1 ]; then
    echo '{"text":"", "tooltip":"点击关闭勿扰模式", "class":"dnd"}'
else
    echo '{"text":"", "tooltip":"点击开启勿扰模式", "class":"active"}'
fi
