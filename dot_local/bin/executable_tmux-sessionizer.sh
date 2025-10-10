#!/usr/bin/env bash
# inspired from https://carlosbecker.com/posts/tmux-sessionizer/

for program in tmux fzf zoxide; do
  command -v "$program" >/dev/null 2>&1 || {
    echo "Not found: $program"
    exit 1
  }
done

if [[ $# -eq 1 ]]; then
  selected=$1
else
  selected=$(zoxide query -l | fzf)
fi

if [[ -z $selected ]]; then
  exit 0
fi

# Get the last two path components
path_suffix="$(echo "$selected" | rev | cut -d'/' -f1-2 | rev)"

# Smart session name generation
selected_name="$(echo "$path_suffix" | sed 's|^\.||' | tr '/.' '__')"

tmux_running="$(pgrep tmux)"

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
  tmux new-session -s "$selected_name" -c "$selected"
  exit 0
fi

if ! tmux has-session -t="$selected_name" 2>/dev/null; then
  tmux new-session -ds "$selected_name" -c "$selected"
fi

tmux switch-client -t "$selected_name"
