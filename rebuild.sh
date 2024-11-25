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
merge misc-patches
pick t3903-stash-racily-clean

# these are completed:
#pick t1401-tar-dir-wo-slash
#pull origin jc/maybe-unused
#pull origin jc/unused-on-windows
#pull origin ps/leakfixes-part-5
#pull origin ps/environ-wo-the-repository
#pull origin ps/mingw-rename

# cooking:
pick t5580-lower-case-drive
pick t7500-in-dir-w-space
merge git-post

# this needs:
# git remote add guij6t https://github.com/j6t/git-gui.git
pull -s subtree guij6t j6t-testing
pull -s subtree guij6t j6t-mingw-build

# this needs:
# git remote add guij6t https://github.com/j6t/gitk.git
pull -s subtree gitk6t j6t-testing

pick snprintf-keep-errno
# needs many adjustments to the test suite:
# pull origin jc/enable-rerere-by-default
pick generic-test-cmp-on-windows
pull origin js/log-remerge-keep-ancestry
pull origin js/range-diff-diff-merges
pick skip-failing-tests
