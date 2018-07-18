for subprofile in .bash_profile.*; do
    [ -f "$subprofile" ] && . "$subprofile"
done

if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi
