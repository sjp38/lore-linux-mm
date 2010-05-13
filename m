Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id AA9896B0204
	for <linux-mm@kvack.org>; Thu, 13 May 2010 05:18:11 -0400 (EDT)
Subject: Re: [PATCH 1/7] hugetlb, rmap: add reverse mapping for hugepage
From: Andi Kleen <andi@halobates.de>
References: <1273737326-21211-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1273737326-21211-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Date: Thu, 13 May 2010 11:18:04 +0200
In-Reply-To: <1273737326-21211-2-git-send-email-n-horiguchi@ah.jp.nec.com> (Naoya Horiguchi's message of "Thu\, 13 May 2010 16\:55\:20 +0900")
Message-ID: <87zl04tb1v.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Mel Gorman <mel@csn.ul.ie>, aarcange@redhat.com, lwoodman@redhat.com, Lee.Schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> writes:

Adding a few more recent hugetlb hackers in cc. Folks, please consider
reviewing the hugetlb.c parts of the original patch kit in linux-mm.

> While hugepage is not currently swappable, rmapping can be useful
> for memory error handler.
> Using rmap, memory error handler can collect processes affected
> by hugepage errors and unmap them to contain error's effect.

Thanks.

I reviewed all the patches and they look good to me. I can merge
them through the hwpoison git tree.

But before merging it there I would like to have some review
and acks from mm hackers on the mm/hugetlb.c parts, which
do (relatively minor) changes outside memory-failure.c

I think you also had a patch for mce-test, can you send me that
one too?

BTW I wonder: did you verify that the 1GB page support works?
I would expect it does, but it would be good to double check.
One would need a Westmere server or AMD Family10h+ system to test that.

> Current status of hugepage rmap differs depending on mapping mode:
> - for shared hugepage:
>   we can collect processes using a hugepage through pagecache,
>   but can not unmap the hugepage because of the lack of mapcount.
> - for privately mapped hugepage:
>   we can neither collect processes nor unmap the hugepage.

I hope these points can be eventually addressed too, but this
is a good first step and closes an important hole in hwpoison
coverage.

-Andi


-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
