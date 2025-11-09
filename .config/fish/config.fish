if status is-interactive
    # Commands to run in interactive sessions can go here
end

alias soulseek="LD_PRELOAD=/usr/lib/libfontconfig.so.1 /usr/bin/soulseek"

set -gx EDITOR nvim
set -gx VISUAL nvim

set -gx PATH $PATH ~/go/bin
