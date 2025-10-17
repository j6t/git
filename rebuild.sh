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
	git --exec-path="$PWD" -c rerere.autoupdate=true pull "$@" || conflicts
	build
}

merge () {
	git -c rerere.autoupdate=true merge --no-edit "$@" || conflicts
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
# not needed, because /usr/bin/sort is now before Window's sort in PATH
#if git merge-base --is-ancestor avoid-windows-sort HEAD
#then
#	build
#else
#	merge avoid-windows-sort
#fi

merge imgdiff
merge misc-patches

# these are completed:

# cooking:
merge git-post

#pick snprintf-keep-errno
# needs many adjustments to the test suite:
# pull origin jc/enable-rerere-by-default

merge progress-wall-clock

pick skip-failing-tests

# Git GUI and Gitk go last so that they can be updated without rebuilding
# the other branches.
# this needs:
# git remote add guij6t https://github.com/j6t/git-gui.git
pull -s subtree guij6t j6t-testing

# this needs:
# git remote add gitk6t https://github.com/j6t/gitk.git
pull -s subtree gitk6t j6t-testing
