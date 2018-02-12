#!/bin/bash
#
# written for BunsenLabs by damo <damo@bunsenlabs.org> May 2015
# modified July 2017
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

# BL-Hydrogen (Crunchbang):
#dmenu_run -b -i -nb '#151617' -nf '#d8d8d8' -sb '#d8d8d8' -sf '#151617'
# BL-Helium Beam theme
# Bottom
#dmenu_run -i -b -nb '#082B4A' -nf '#ADD8E6' -sb '#446F6C' -sf '#151617'
# Top
dmenu_run -i -nb '#082B4A' -nf '#ADD8E6' -sb '#446F6C' -sf '#151617'
