#!/bin/bash
#
## Bunsenlabs User config files
## All default BunsenLabs user config files are located in /usr/share/bunsen/skel.
## The script bl-user-setup copies them to the user $HOME directory on first login.
## See more info with command 'bl-user-setup --help'
#
# BL-Beryllium theme colours
#
# written for BunsenLabs by damo <damo@bunsenlabs.org> May 2015
# modified July 2017
# modified April 2022
#
# -nb    normal background colour
# -nf    normal foreground colour
# -sb    selected background colour
# -sf    selected foreground colour
#
# -b    place menu at bottom (otherwise appears at top)
#
# See 'man dmenu' for more information.

USAGE="\n  To start dmenu at the top or bottom of the screen,\n\
  add or remove -b in the dmenu_run command in dmenu-bind.sh.\n\
  -b     locate at bottom\n\n\
  To change colours, edit the options:\n\n\
  -nb    normal background colour\n\
  -nf    normal foreground colour\n\
  -sb    selected background colour\n\
  -sf    selected foreground colour\n\n\
  Get all configuration options with 'man dmenu'.\n"

if [[ $# = 1 ]]; then
    case $1 in
        -h|--help   ) echo -e "$USAGE"
        exit 0;;
        *           ) echo -e "\n  Invalid command argument\n"
        exit 1;;
    esac
fi

# BL-Boron colours for aqua or dark
# Top
dmenu_run -i -nb '#1E2B2E' -nf '#D7E8E8' -sb '#D7E8E8' -sf '#1E2B2E'
# Bottom
#dmenu_run -i -b -nb '#1E2B2E' -nf '#D7E8E8' -sb '#D7E8E8' -sf '#1E2B2E'
