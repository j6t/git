#!/bin/sh
# Copyright (c) 2017 Johannes Sixt

SUBDIRECTORY_OK=Yes
OPTIONS_SPEC="\
git post dest-branch [source-rev]
--
"
. git-sh-setup

while test $# != 0
do
	case "$1" in
	--)	shift; break;;
	-*)	usage;;
	*)	break;;
	esac
	shift
done

dest=$(git rev-parse --verify --symbolic-full-name "$1") || exit
if test -z "$dest"
then
	die "$(gettext "Destination must be a branch tip")"
fi

shift
case $# in
0)	set -- HEAD;;
1)	: good;;
*)	usage;;
esac

# apply change to a temporary index
tmpidx=$GIT_DIR/index-post-$$
git read-tree --index-output="$tmpidx" "$dest" || exit
GIT_INDEX_FILE=$tmpidx
export GIT_INDEX_FILE
trap 'rm -f "$tmpidx"' 0 1 2 15

git diff-tree -p --binary -M -C "$1" | git apply --cached || exit

newtree=$(git write-tree) &&
newrev=$(
	eval "$(get_author_ident_from_commit "$1")" &&
	export GIT_AUTHOR_NAME GIT_AUTHOR_EMAIL GIT_AUTHOR_DATE
	git-cat-file commit "$1" | sed -e '1,/^$/d' |
	git commit-tree $newtree -p "$dest"
) || exit

if git check-ref-format "$dest"
then
	set_reflog_action post
	subject=$(git log --no-walk --pretty=%s "$newrev") &&
	git update-ref -m "$GIT_REFLOG_ACTION: $subject" "$dest" "$newrev" || exit
fi
if test -z "$GIT_QUIET"
then
	git rev-list -1 --oneline "$newrev"
fi
