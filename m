Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A7C126B0246
	for <linux-mm@kvack.org>; Sat,  8 May 2010 15:53:43 -0400 (EDT)
Date: Sat, 8 May 2010 12:51:08 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
 the wrong VMA information
In-Reply-To: <20100508180412.GT5941@random.random>
Message-ID: <alpine.LFD.2.00.1005081247480.3711@i5.linux-foundation.org>
References: <1273188053-26029-1-git-send-email-mel@csn.ul.ie> <1273188053-26029-2-git-send-email-mel@csn.ul.ie> <20100508153922.GS5941@random.random> <alpine.LFD.2.00.1005081000490.3711@i5.linux-foundation.org> <20100508180412.GT5941@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>



On Sat, 8 May 2010, Andrea Arcangeli wrote:
> 
> There is no broken (as in kernel crashing) locking in my THP
> patches.

It's not about crashing. It's about being a totally unmaintainable mess, 
with ad-hoc temporary allocations, and loops over an unknown number of 
spinlocks.

That's _broken_. B. R. O. K. E. N.

And in all cases there are fixes that I've pointed out. If you can't see 
that, then that's _your_ problem. If you (or others) want your code 
merged, then it had better _fix_ the total disaster before merging. It's 
that simple.

The "lock root" thing you complain should also be easily fixable, by 
keeping the root lock a separate issue from walking the actual anon_vma 
(ie walk the anon_vma, but lock the root). You still don't have to lock 
the whole list.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
