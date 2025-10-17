#!/usr/bin/env bash
chosen=$(echo -e "  关机\n  重启\n  锁屏\n󰍃  注销\n󰜺  取消" | wofi --dmenu --width 200 --height 200 --prompt "系统操作")

case $chosen in
  "  关机") systemctl poweroff ;;
  "  重启") systemctl reboot ;;
  "  锁屏") loginctl lock-session ;;
  "  注销") niri msg action quit ;;
  *) exit 0 ;;
esac
