Message-ID: <3C866821.6DF3F65C@zip.com.au>
Date: Wed, 06 Mar 2002 11:04:01 -0800
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] struct page shrinkage
References: <OFC19C560E.A00F9111-ON85256B74.006633D4@pok.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bulent Abali <abali@us.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Bulent Abali wrote:
> 
> extern struct page_state {
>              unsigned long nr_dirty;
>              unsigned long nr_locked;
> } ____cacheline_aligned page_states[NR_CPUS];
> 
> This is perfect.   Looks like, if a run summation over all the CPUs I will
> get the total locked and dirty pages, provided mm.h macros are respected.

That's correct.  And the mm.h macros *are* respected.  That patch
ensures that they are.

It goes as far as to rename PG_locked and PG_dirty to PG_locked_dontuse
and PG_dirty_dontuse.

I'll be adding page_cache_size to the above struct, at least.

The "run summation" function is already there, btw: get_page_state().

> What is the outlook for inclusion of this patch in the main kernel?  Do you
> plan to submit or have been included yet?

Well it's all a part of a work to aggressively improve the efficiency
of regular file I/O.  I don't know if the big grand plan will be successful
yet.  At this time, it's thumbs up - way up.

Nor do I know if this is a direction in which Linus wishes to take
his kernel.

But this change, the readahead changes, the pdflush pool and a few other
pieces I have planned are probably appropriate for the base kernel
irrespective of the end outcome.

We'll see...

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
