Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0E7B96200BD
	for <linux-mm@kvack.org>; Sat,  8 May 2010 13:05:27 -0400 (EDT)
Date: Sat, 8 May 2010 10:02:50 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm,migration: Prevent rmap_walk_[anon|ksm] seeing
 the wrong VMA information
In-Reply-To: <20100508153922.GS5941@random.random>
Message-ID: <alpine.LFD.2.00.1005081000490.3711@i5.linux-foundation.org>
References: <1273188053-26029-1-git-send-email-mel@csn.ul.ie> <1273188053-26029-2-git-send-email-mel@csn.ul.ie> <20100508153922.GS5941@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>



On Sat, 8 May 2010, Andrea Arcangeli wrote:
> 
> I'm simply not going to support the degradation to the root anon_vma
> complexity in aa.git, except for strict merging requirements [ ..]

Goodie. That makes things easier for me - there's never going to be any 
issue of whether I need to even _think_ about merging the piece of crap.

In other words - if people want anything like that merged, you had better 
work on cleaning up the locking. Because I absolutely WILL NOT apply any 
of the f*ckign broken locking patches that I've seen, when I've personally 
told people how to fix the thing.

In other words, it's all _your_ problem.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
