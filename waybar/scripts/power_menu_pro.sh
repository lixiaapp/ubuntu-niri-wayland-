#!/usr/bin/env bash

# 设置错误处理
set -euo pipefail

# 检查wofi是否可用
if ! command -v wofi >/dev/null 2>&1; then
    echo "错误：wofi未安装或不在PATH中" >&2
    exit 1
fi

# 显示菜单并获取选择
menu_options="  关机\n  重启\n  锁屏\n󰍃  注销\n󰜺  取消"
chosen=$(echo -e "$menu_options" | wofi --dmenu --width 200 --height 200 --prompt "系统操作" 2>/dev/null || echo "")

# 如果没有选择或选择为空，直接退出
if [[ -z "$chosen" ]]; then
    exit 0
fi

# 处理选择
case "$chosen" in
    "  关机")
        if command -v systemctl >/dev/null 2>&1; then
            shutdown
        else
            echo "错误：shutdown命令不可用" >&2
            exit 1
        fi
        ;;
    "  重启")
        if command -v systemctl >/dev/null 2>&1; then
            shutdown -r
        else
            echo "错误：shutdown -r命令不可用" >&2
            exit 1
        fi
        ;;
    "  锁屏")
        if command -v loginctl >/dev/null 2>&1; then
            loginctl lock-session
        else
            echo "错误：loginctl命令不可用" >&2
            exit 1
        fi
        ;;
    "󰍃  注销")
        if command -v niri >/dev/null 2>&1; then
            niri msg action quit
        else
            echo "错误：niri命令不可用" >&2
            exit 1
        fi
        ;;
    "󰜺  取消")
        exit 0
        ;;
    *)
        # 未知选择，安全退出
        exit 0
        ;;
esac
