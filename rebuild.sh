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
#pull origin ss/msvc-strcasecmp
#pull origin tb/use-common-win32-pathfuncs-on-cygwin
#pull origin en/rebase-merge-on-sequencer
#pull origin ag/sequencer-reduce-rewriting-todo
#pull origin nd/diff-parseopt-3
#pull origin js/init-db-update-for-mingw
#pull origin en/unicode-in-refnames
#pull origin js/spell-out-options-in-tests
#pull origin pw/rebase-i-internal
#pull origin sg/overlong-progress-fix
#pull origin ss/msvc-path-utils-fix
#pull origin js/difftool-no-index
#pull origin js/t5580-unc-alternate-test
#pull origin js/t6500-use-windows-pid-on-mingw
#pull origin tt/no-ipv6-fallback-for-winxp
#pull origin js/rebase-config-bitfix
#pull origin js/rebase-deprecate-preserve-merges

# cooking:
pick t5580-lower-case-drive
pick t7500-in-dir-w-space
merge git-post
#pull origin dl/difftool-mergetool
#merge mergetool-processes
pull origin js/mergetool-optim
pull origin ps/stash-in-c
pull origin mk/use-size-t-in-zlib
pull origin dl/rebase-i-keep-base
pull origin bl/userdiff-octave
pull origin ml/userdiff-rust
pull origin en/fast-export-encoding
pull origin js/rebase-cleanup
pull origin pw/rebase-edit-message-for-replayed-merge
pull origin sg/rebase-progress
pull origin js/gcc-8-and-9
pull origin js/mingw-use-utf8
pull origin js/rebase-reschedule-applies-only-to-interactive
pull origin js/t0001-case-insensitive
pull origin js/mingw-gcc-stack-protect
pull origin kb/windows-force-utf8
pull origin jh/msvc
pull origin cb/windows-manifest
pull origin js/unmap-before-ext-diff
pull origin ds/midx-expire-repack
pull origin kb/mingw-set-home
pull origin js/mingw-spawn-with-spaces-in-path
pick skip-failing-tests
