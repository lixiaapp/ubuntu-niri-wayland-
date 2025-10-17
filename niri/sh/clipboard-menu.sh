#!/usr/bin/env bash
# clipboard-menu.sh - 兼容文本与图片的剪贴板历史选择

# 获取历史列表，文本项直接显示内容，图片项显示 [image/png] 等标记
selection=$(cliphist list \
    | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' \
    | wofi --show dmenu --prompt "Clipboard History:")

# 如果没有选择就退出
[ -z "$selection" ] && exit 0

# 解码所选内容到剪贴板
cliphist decode <<< "$selection" | wl-copy

# 检测是否为图片 MIME 类型
mime_type=$(file -b --mime-type <(cliphist decode <<< "$selection"))

if [[ "$mime_type" == image/* ]]; then
    # 临时保存缩略图
    tmpfile="/tmp/cliphist_preview.png"
    cliphist decode <<< "$selection" > "$tmpfile"
    # 使用 swayimg 或其他 Wayland 图片预览工具显示
    swayimg "$tmpfile" &
fi
