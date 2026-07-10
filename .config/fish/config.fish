if status is-interactive
    # Commands to run in interactive sessions can go here
end

alias clear='clear && printf "\e[3J"'

set -gx EDITOR nvim
set -gx VISUAL nvim

set -gx PATH $PATH ~/go/bin

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# opencode
fish_add_path /home/kuma/.opencode/bin
