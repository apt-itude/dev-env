alias ls='ls --color=auto'
alias ll='ls -lsF'
alias la='ls -lsaF'

alias grep='grep --color=auto'

alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'

alias cl='clear'

alias rmpycache='find . | grep -E "(__pycache__|\.pyc$)" | xargs rm -rf'

function title {
    echo -n -e "\033]0;$1\007"
}

for subaliases in .bash_aliases.*; do
    [ -f "$subaliases" ] && . "$subaliases"
done
