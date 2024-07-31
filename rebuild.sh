#!/bin/bash
# update this script first!
#
# git log --first-parent --decorate --oneline --reverse origin..

head=none jobs=-j4
while test $# -ne 0
do
	case "$1" in
	-s)	# skip initial build
		head=skip
		;;
	-j*)
		jobs=$1
		;;
	*)
		echo >&2 "usage: $0 [-s]"
	esac
	shift
done

build () {
	local newhead=$(git rev-parse HEAD)
	if test "$newhead" != "$head"
	then
		test "$head" = skip ||
			make $jobs
		head=$newhead
	fi
}

conflicts () {
	git diff-files --quiet && git commit --no-edit
}

pull () {
	git -c rerere.autoupdate=true pull "$@" || conflicts
	build
}

merge () {
	git -c rerere.autoupdate=true merge "$@" || conflicts
	build
}

pick () {
	if ! git merge-base --is-ancestor "$1" HEAD
	then
		git cherry-pick "$@"
		git branch -f "$1"
	fi
	build
}

set -e
set -x

# this is an essential patch
if git merge-base --is-ancestor avoid-windows-sort HEAD
then
	build
else
	merge avoid-windows-sort
fi

merge imgdiff
pull -s subtree ../gitk master
merge misc-patches
pick t3903-stash-racily-clean

# these are completed:
#pull -s subtree pratyush py/call-do-quit-before-exit
#pull -s subtree pratyush bw/commit-scrollbuffer
#pull -s subtree pratyush bp/widget-focus-hotkeys
#pull -s subtree pratyush py/revert-hunks-lines
#pull -s subtree pratyush bw/amend-checkbutton
#pull -s subtree pratyush bp/amend-toggle-bind
#pull -s subtree pratyush py/readme
#pull origin rs/t3920-crlf-eating-grep-fix
#pull origin js/t3920-shell-and-or-fix
#pull origin js/drop-mingw-test-cmp
#pull origin js/t0021-windows-pwd

# cooking:
pick t5580-lower-case-drive
pick t7500-in-dir-w-space
merge git-post
# pull origin mk/use-size-t-in-zlib

# this needs:
# git remote add guij6t https://github.com/j6t/git-gui.git
pull -s subtree guij6t j6t-testing
pull -s subtree guij6t j6t-mingw-build

pick snprintf-keep-errno
# needs many adjustments to the test suite:
# pull origin jc/enable-rerere-by-default
pick t1401-tar-dir-wo-slash
pick generic-test-cmp-on-windows
pick skip-failing-tests
