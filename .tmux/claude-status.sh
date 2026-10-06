#!/usr/bin/env bash
set -euo pipefail

[[ -z "${TMUX:-}" || -z "${TMUX_PANE:-}" ]] && exit 0

hook_event_name="$(jq -r '.hook_event_name // ""')"

if [[ "$hook_event_name" == "SessionEnd" ]]; then
    # ウィンドウローカルの設定を無効にする
    exec tmux set-option -uw -t "$TMUX_PANE" automatic-rename-format
fi
if [[ "$hook_event_name" == "SessionStart" ]]; then
    # ウィンドウローカルの設定を有効にする
    tmux set-option -w -t "$TMUX_PANE" automatic-rename on
fi

case "$hook_event_name" in
    SessionStart)     icon="[ ]" ;;
    UserPromptSubmit) icon="[>]" ;;
    Stop)             icon="[v]" ;;
    Notification)     icon="[!]" ;;
    *)                exit 0     ;;
esac

# ウィンドウローカルのフォーマットを設定する
format="$(tmux show-options -gwv automatic-rename-format)"
exec tmux set-option -w -t "$TMUX_PANE" automatic-rename-format "$icon $format"
