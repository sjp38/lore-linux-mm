Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C6EAC6B01F9
	for <linux-mm@kvack.org>; Tue, 11 May 2010 13:13:41 -0400 (EDT)
Date: Tue, 11 May 2010 10:11:03 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] mm,migration: Avoid race between shift_arg_pages() and
 rmap_walk() during migration by not migrating temporary stacks
In-Reply-To: <20100511085752.GM26611@csn.ul.ie>
Message-ID: <alpine.LFD.2.00.1005111009500.3711@i5.linux-foundation.org>
References: <20100511085752.GM26611@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>



On Tue, 11 May 2010, Mel Gorman wrote:
> 
> This patch closes the most important race in relation to exec and
> migration. With it applied, the swapops bug is no longer triggering for
> known problem workloads. If you pick it up, it should go with the other
> mmmigration-* fixes in mm.

Ack. _Much_ better and clearer.

I'm not entirely sure we need that "maybe_stack" (if we need it, that 
would sound like a problem anyway), but I guess it can't hurt either.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
