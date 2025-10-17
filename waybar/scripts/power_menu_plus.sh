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
        if command -v shutdown >/dev/null 2>&1; then
            # 先执行shutdown +1（60秒后关机）
            shutdown
            
            # 显示二次确认窗口，让用户选择立即关机或取消关机
            response=$(echo -e "✅ 立即关机\n❌ 取消关机" | wofi --dmenu --width 300 --height 150 --prompt "已安排60秒后关机" 2>/dev/null || echo "")
            
            # 如果用户选择立即关机，执行shutdown now
            if [[ "$response" == "✅ 立即关机" ]]; then
                shutdown now
            # 如果用户选择取消关机，执行shutdown -c
            elif [[ "$response" == "❌ 取消关机" ]]; then
                shutdown -c
            fi
        else
            echo "错误：shutdown命令不可用" >&2
            exit 1
        fi
        ;;
    "  重启")
        if command -v shutdown >/dev/null 2>&1; then
            # 先执行shutdown -r +1（60秒后重启）
            shutdown -r
            
            # 显示二次确认窗口，让用户选择立即重启或取消重启
            response=$(echo -e "✅ 立即重启\n❌ 取消重启" | wofi --dmenu --width 300 --height 150 --prompt "已安排60秒后重启" 2>/dev/null || echo "")
            
            # 如果用户选择立即重启，执行shutdown -r now
            if [[ "$response" == "✅ 立即重启" ]]; then
                shutdown -r now
            # 如果用户选择取消重启，执行shutdown -c
            elif [[ "$response" == "❌ 取消重启" ]]; then
                shutdown -c
            fi
        else
            echo "错误：shutdown -r命令不可用" >&2
            exit 1
        fi
        ;;
    "  锁屏")
        if command -v loginctl >/dev/null 2>&1; then
            bash -c '(sleep 0s; swaylock)'
        else
            echo "错误：swaylock命令不可用" >&2
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
        # 执行取消关机命令
        if command -v shutdown >/dev/null 2>&1; then
            shutdown -c
        else
            echo "错误：shutdown -c命令不可用" >&2
            exit 1
        fi
        ;;
    *)
        # 未知选择，安全退出
        exit 0
        ;;
esac