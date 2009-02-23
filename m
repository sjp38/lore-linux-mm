Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 234286B00DF
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 15:09:59 -0500 (EST)
Subject: Re: [PATCH] mm: gfp_to_alloc_flags()
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20090223181713.GS6740@csn.ul.ie>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie>
	 <1235390103.4645.80.camel@laptop>  <20090223181713.GS6740@csn.ul.ie>
Content-Type: text/plain
Date: Mon, 23 Feb 2009 21:09:44 +0100
Message-Id: <1235419784.4645.704.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-02-23 at 18:17 +0000, Mel Gorman wrote:

> > 
> > -       if (((p->flags & PF_MEMALLOC) || unlikely(test_thread_flag(TIF_MEMDIE)))
> > -                       && !in_interrupt()) {
> > -               if (!(gfp_mask & __GFP_NOMEMALLOC)) {
> > 
> 
> At what point was this code deleted?

You moved it around a bit, but it ended up here:

> > -static inline int is_allocation_high_priority(struct task_struct *p,
> > -							gfp_t gfp_mask)
> > -{
> > -	if (((p->flags & PF_MEMALLOC) || unlikely(test_thread_flag(TIF_MEMDIE)))
> > -			&& !in_interrupt())
> > -		if (!(gfp_mask & __GFP_NOMEMALLOC))
> > -			return 1;
> > -	return 0;
> > -}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
