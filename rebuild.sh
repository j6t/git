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
pull -s subtree ../git-gui master
merge misc-patches
merge mingw-send-pack
#abendoned: merge rebase-p-first-parent
#pick win32-winnt
pick t3903-stash-racily-clean

# these are completed:
#pull origin lt/date-human
#pick no-hide-dot-files
#pick strbuf-vinsertf-fix

# cooking:
pick t5580-lower-case-drive
pick t7500-in-dir-w-space
merge git-post
merge mergetool-processes
pull origin ps/stash-in-c
pull origin mk/use-size-t-in-zlib
pull origin ss/msvc-strcasecmp
pull origin tb/use-common-win32-pathfuncs-on-cygwin
pull origin en/rebase-merge-on-sequencer
pull origin ag/sequencer-reduce-rewriting-todo
pull origin nd/diff-parseopt-3
pick skip-failing-tests
