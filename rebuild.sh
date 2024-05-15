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
#not necessary anymore says Dscho
#merge mingw-send-pack
#abendoned: merge rebase-p-first-parent
#pick win32-winnt
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
# git remote add pratyush https://github.com/prati0100/git-gui.git
# merge -s subtree git-gui-revert-bw-revert-hunk
# pull -s subtree pratyush master
pull -s subtree pratyush py/reload-config
pull -s subtree pratyush bp/select-staged-on-commit-focus
pull -s subtree pratyush sh/auto-rescan
pick snprintf-keep-errno
merge -s subtree git-gui-auto-rescan
# needs many adjustments to the test suite:
# pull origin jc/enable-rerere-by-default
pick t1401-tar-dir-wo-slash
pick nuke-mingw-test-cmp
pull origin jc/rerere-cleanup
pick skip-failing-tests
