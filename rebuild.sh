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
#pull origin en/merge-recursive-tests
#pull origin cc/tests-without-assuming-ref-files-backend
#pull origin en/rebase-i-microfixes
#pull origin bp/test-drop-caches-for-windows
#pull origin en/t6036-merge-recursive-tests
#pull origin en/t6036-recursive-corner-cases
#pull origin en/t6042-insane-merge-rename-testcases
#pull origin en/t7405-recursive-submodule-conflicts
#pull origin js/vscode
#pull origin jk/banned-function
#pull origin js/mingw-o-append
#pull origin js/mingw-ns-filetime
#pull origin js/mingw-load-sys-dll
#pull origin js/mingw-getcwd
#pull origin js/mingw-wants-vista-or-above
#pull origin js/mingw-perl5lib
#pull origin js/mingw-utf8-env

# cooking:
pick t5580-lower-case-drive
pick t7500-in-dir-w-space
merge git-post
merge mergetool-processes
pull origin lt/date-human
#pull origin pk/rebase-in-c
#pull origin ag/rebase-i-in-c
pull origin ps/stash-in-c
#pull origin pk/rebase-in-c-2-basic
#pick declare-get-merge-bases
#pull origin pk/rebase-in-c-3-acts
#pull origin pk/rebase-in-c-4-opts
#pull origin pk/rebase-in-c-5-test
#pull origin js/rebase-in-c-5.5-work-with-rebase-i-in-c
#pull origin pk/rebase-in-c-6-final
#pull origin nd/clone-case-smashing-warning
#pull origin js/larger-timestamps
#pull origin mk/http-backend-content-length
#pull origin en/sequencer-empty-edit-result-aborts
#pull origin js/mingw-default-ident
#pull origin js/mingw-http-ssl
#pull origin js/pack-objects-mutex-init-fix
pull origin mk/use-size-t-in-zlib
#pull origin ss/rename-tests
#pull gitgadget pr-43/dscho/rebase-i-break-v1
#pull origin js/diff-notice-has-drive-prefix
#pull origin js/mingw-isatty-and-dup2
#pull origin js/mingw-http-ssl
#pull origin sg/test-rebase-editor-fix
#pull origin js/rebase-i-shortopt
#pull origin js/rebase-p-tests
#pull origin nd/pthreads
#pull origin sh/mingw-safer-compat-poll
#pull origin js/mingw-res-rebuild
#pick diff-abs-path
#pull gitgadget pr-77/dscho/mingw-CreateHardLink-v1
#pull origin js/mingw-create-hard-link
#pull gitgadget pr-80/dscho/mingw-modernize-pthread_cond_t-v1
#pull origin lj/mingw-pthread-cond
#pull origin js/mingw-msdn-url
#pull origin gl/bundle-unlock-before-aborting
#pull origin jk/close-duped-fd-before-unlock-for-bundle
#pull origin nd/clone-case-smashing-warning
#pick no-hide-dot-files
pull origin ss/msvc-strcasecmp
pull origin js/commit-graph-chunk-table-fix
pull origin tb/use-common-win32-pathfuncs-on-cygwin
#pull origin tt/bisect-in-c
pull origin tg/t5570-drop-racy-test
pull origin js/t6042-timing-fix
pull origin js/mingw-unc-path-w-backslashes
#pull gitgadget pr-94/dscho/unc-path-w-backslashes-v1
pull origin en/rebase-merge-on-sequencer
pull origin ag/sequencer-reduce-rewriting-todo
pull origin tt/bisect-in-c
pick strbuf-vinsertf-fix
pick skip-failing-tests
