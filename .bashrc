#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'

PS1='[\u@\h \W]\$ '

export BROWSER=librewolf
export EDITOR=nvim

source /usr/share/nvm/init-nvm.sh

. "$HOME/.cargo/env"

alias soulseek="LD_PRELOAD=/usr/lib/libfontconfig.so.1 /usr/bin/soulseek"
