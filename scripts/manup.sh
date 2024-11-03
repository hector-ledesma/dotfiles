#!/bin/zsh
# TODO: Add to neovim a way to open a floating window of all lines matching a pattern
# that way, if I seach for $flag, I'll see all lines w/ that flag mentioned.
if [ $# -lt 1 ]; then
	echo "Missing what to man, bozo."
	exit 1
fi

MANPAGE=$(man $1)

if [ $? -ne 0 ]; then
	exit $?
fi

echo $MANPAGE | nvim - -R --cmd "setfiletype man"
