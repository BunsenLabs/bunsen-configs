#!/bin/sh
# genman.sh
# script to generate man files from executables' --help options,
# using help2man.
# Tested on Dash, should work with other POSIX shells.

# Put this script in the package source debian/ directory
# (or some other location, to taste),
# add a file debian/genman-list, debian/<packagename>.genman-list
# or debian/<packagename>.<section-number>.genman-list
# with a list of the executables whose manpages are to be built.
# Shell globs may be used.
# If set, <section-number> determines the manual section,
# otherwise section 1 is used by default.
# Multiple genman-list files can be used, for source building
# multiple packages, or for different manual sections.
#
# Built manpages will be put in debian/genman-pages/, and
# their paths will be appended to an existing debian/*manpages file,
# or put in a new manpages or <packagename>.manpages file.
#
# genman.sh --clean will return everything to its previous state.
#
# Run the script manually before building the package,
# or to auto-run, add this to debian/rules:
# (adjust the path to genman.sh if necessary)
###
#override_dh_installman:
#	debian/genman.sh
#	dh_installman
#
#override_dh_clean:
#	dh_clean
#	debian/genman.sh --clean
#

set -e

# default if genman-list has no digit in name
default_section=1

# BunsenLabs generic content
includes="[authors]
Written by the BunsenLabs team.

[reporting bugs]
Please report bugs at
https://github.com/BunsenLabs/${src_name}/issues

[see also]
The BunsenLabs forums may be able to answer your questions

https://forums.bunsenlabs.org
"

HELP="    genman.sh: generate man pages from executables \"--help\" options
Options:
    --clean     Return everything in the package debian/ directory
                to the state it was in before running the script.
    -h --help   Show this message.

This is a wrapper script around help2man which automates the
generation of simple man pages from the output of the \"--help\" option,
along with information from dpkg,
and configuration files in the package source debian/ directory.

CONFIGURATION:

 The script will look for files in debian/:
 <packagename>.<section>.genman-list
 <packagename>.genman-list
 genman-list
 If <section> ([1-8]) is missing, assume 1.
 If <packagename> is also missing, get from dpkg.
 The file should have a list of the executables
 (paths relative to the package root) whose manpages are to be built.
 Shell globs may be used.
 Multiple genman-list files can be used, for source building
 multiple packages, or for different manual sections.

Built manpages will be put in debian/genman-pages/, and
their paths will be appended to an existing debian/*manpages file,
or put in a new manpages or <packagename>.manpages file.

The script can be located anywhere, but should be run
from the package source root directory.
Run it manually before building the package,
or to auto-run, add this to debian/rules:
(adjust the path to genman.sh if necessary)

override_dh_installman:
	debian/genman.sh
	dh_installman

override_dh_clean:
	dh_clean
	debian/genman.sh --clean

"

### it may not be necessary to edit below this line ###

manpg_dir=debian/genman-pages
include_file=debian/genman.include

### functions ###

# pass file with list of executables to make manpages for,
# with file or shell glob on each line
build_mans() {
    local line file
    while read -r line
    do
        [ -f "$line" ] && {
            mk_man "$line"
            continue
        }
        for file in $line # shell glob
        do
            [ -f "$file" ] || continue
            mk_man "$file"
        done
    done < "$1"
}

# pass executable file
mk_man() {
    local exec="$1"
    local cmd=${1##*/}
    local manfile="${manpg_dir}/${cmd}.${section}"
    grep "${cmd}\(.[1-8]\)\? *\$" "${manpages_file}" >/dev/null 2>&1 && {
        echo "$0: ${cmd} already in ${manpages_file}, skipping"
        return 0
    }
    chmod +x "$exec"
    default_desc="a script provided by ${pkg_name}"
    desc="$( "$exec" --help | sed -rn "/^ *$cmd/ {s/^ *$cmd( -|:| is)? *//p;q}")"
    [ -z "$desc" ] && desc="$default_desc"
    help2man "$exec" --no-info --no-discard-stderr --version-string="$cmd $pkg_ver" --section="$section" --name="$desc" --include="$include_file" | sed "s|$HOME|~|g" > "$manfile"
    chmod -x "$exec"
    echo "$manfile" >> "${manpages_file}"
}

### script starts here ###

case $1 in
--clean)
    rm -rf "$manpg_dir"
    # avoid cleaning existing files
    [ -f "$include_file" ] && rm -f debian/*manpages
    rm -rf "$include_file"
    for i in debian/*.genman.bckp # restore backups
    do
        [ -f "$i" ] || continue
        mv "$i" "${i%.genman.bckp}"
    done
    exit 0
    ;;
--help|-h)
	echo "$HELP"
	exit 0
	;;
esac

src_name=$(dpkg-parsechangelog -S Source) || {
    echo "$0: Not in debian source directory?" >&2
    exit 1
}
pkg_name="$src_name" # will be replaced if <packagename>.*.genman-list found
pkg_ver=$(dpkg-parsechangelog -S Version)

mkdir -p "$manpg_dir"

# avoid multiple runs
[ -f "$include_file" ] && {
    echo "$0: manpages already built" >&2
    exit 1
}

# backup any existing manpages files
for file in debian/*manpages
do
    [ -f "$file" ] || continue
    cp "$file" "$file".genman.bckp
done

cat <<EOF > "$include_file"
$includes
EOF

for list in debian/*.genman-list
do
    [ -f "$list" ] || continue
    found_list=true
    pkg_name="${list##*/}"
    pkg_name="${pkg_name%.genman-list}"
# If filename is <package>.[1-9].genman-list
# then digit determines section, otherwise use default set above.
    case $pkg_name in
    *.[1-8])
        section="${pkg_name##*.}"
        pkg_name="${pkg_name%.*}"
        ;;
    *)
        section="$default_section"
        ;;
    esac
    manpages_file=debian/${pkg_name}.manpages
    build_mans "$list"
done

# simple option
if [ "$found_list" != true ] && [ -f debian/genman-list ]
then
    manpages_file=debian/manpages
    build_mans debian/genman-list
fi
