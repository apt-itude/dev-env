export HISTCONTROL=ignoredups

for subrc in .bashrc.*; do
    [ -f "$subrc" ] && . "$subrc"
done

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f ~/.bash_prompt ]; then
    . ~/.bash_prompt
fi

if [ -f ~/.dircolors ]; then
    eval `dircolors -b ~/.dircolors`
fi
