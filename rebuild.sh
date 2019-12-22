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
#pull origin dl/difftool-mergetool
#pull origin dl/rebase-i-keep-base
#pull origin bc/reread-attributes-during-rebase
#pull origin bw/rebase-autostash-keep-current-branch
#pull origin nd/diff-parseopt
#pull origin pw/rebase-i-show-HEAD-to-reword
#pull origin tg/t0021-racefix
#pull origin js/visual-studio
#pull origin js/gitdir-at-unc-root
#pull origin ar/mingw-run-external-with-non-ascii-path
#pull origin sb/userdiff-dts
#pull origin tb/file-url-to-unc-path
#pull origin tg/t0021-racefix
#pull origin sg/progress-fix
#pull origin dl/octopus-graph-bug
#pull origin js/diff-rename-force-stable-sort
#pull -s subtree pratyush py/call-do-quit-before-exit
#pull -s subtree pratyush bw/commit-scrollbuffer
#pull -s subtree pratyush bp/widget-focus-hotkeys
#pull -s subtree pratyush py/revert-hunks-lines
#pull -s subtree pratyush bw/amend-checkbutton
#pull -s subtree pratyush bp/amend-toggle-bind
#pull -s subtree pratyush py/readme

# cooking:
pick t5580-lower-case-drive
pick t7500-in-dir-w-space
merge git-post
pull origin mk/use-size-t-in-zlib
pull origin jc/log-graph-simplify
pull origin js/git-path-head-dot-lock-fix

# this needs:
# git remote add pratyush https://github.com/prati0100/git-gui.git
merge -s subtree git-gui-revert-bw-revert-hunk
pull -s subtree pratyush master
pull -s subtree pratyush py/reload-config
pull -s subtree pratyush js/hooks-path
pull -s subtree pratyush bp/select-staged-on-commit-focus
#pull https://github.com/gitgitgadget/git pr-480/dscho/mingw-inherit-only-std-handles-set-errno-v2
pick skip-failing-tests
