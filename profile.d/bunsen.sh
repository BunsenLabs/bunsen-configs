# /etc/profile.d/bunsen.sh
# BunsenLabs message

if [ ! -f "${HOME}/.config/bunsen/bl-setup" ] && [ "$TERM" = "linux" ]; then
    echo "
There seem to be no configuration files for the BunsenLabs desktop.
Please run 'bl-user-setup' if you'd like to generate them.
"
fi
