#!/bin/sh

test_description='test git post

We build this history:

   A--B--C  <-- master, HEAD
  /
 O          <-- side-base, side

Then we post B and C on top of branch "side":

   A--B--C  <-- master, HEAD
  /
 O          <-- side-base
  \
   B*--C*   <-- side

B has a different author, which must be copied to B*.
'

. ./test-lib.sh

test_expect_success setup '

	printf "a%s\n" 1 2 3 4 >file-a &&
	printf "b%s\n" 5 6 7 8 >file-b &&

	test_tick &&
	git add file-a file-b &&
	git commit -m initial &&
	git tag side-base &&

	test_tick &&
	echo "Advance master" >>file-a &&
	git commit -a -m advance-master &&

	test_tick &&
	echo "Unrelated fix" >>file-b &&
	GIT_AUTHOR_NAME="S O Else" git commit -a -m fix-for-b &&

	test_tick &&
	echo "Another fix" >>file-b &&
	git commit -a -m another-fix-for-b
'

test_expect_success 'post two commits on top of side' '

	git branch -f side side-base &&
	test_tick &&
	git post side HEAD^ &&
	test_tick &&
	git post side &&

	git log --pretty="%at %an %ae %s" HEAD~2.. >expect &&
	git log --pretty="%at %an %ae %s" side-base..side >actual &&

	test_cmp expect actual &&
	git cat-file blob side:file-b >actual &&
	test_cmp file-b actual &&

	git diff --exit-code side-base side -- file-a	# no change
'

test_expect_success 'post requiring merge resolution fails' '

	git branch -f side side-base &&
	test_must_fail git post side HEAD
'

test_expect_success 'cannot post onto arbitrary commit name' '

	git branch -f side side-base &&
	test_must_fail git post side^0 HEAD^
'

test_done
