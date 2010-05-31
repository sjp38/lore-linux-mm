Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D27366B01C1
	for <linux-mm@kvack.org>; Mon, 31 May 2010 09:22:06 -0400 (EDT)
Received: by pvc21 with SMTP id 21so1711673pvc.14
        for <linux-mm@kvack.org>; Mon, 31 May 2010 06:22:05 -0700 (PDT)
Date: Mon, 31 May 2010 22:21:59 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [patch] mm: vmap area cache
Message-ID: <20100531132159.GA3555@barrios-desktop>
References: <20100531080757.GE9453@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100531080757.GE9453@laptop>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Steven Whitehouse <swhiteho@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 31, 2010 at 06:07:57PM +1000, Nick Piggin wrote:
> Hi Andrew,
> 
> Could you put this in your tree? It could do with a bit more testing. I
> will update you with updates or results from Steven.
> 
> Thanks,
> Nick
> --
> 
> Provide a free area cache for the vmalloc virtual address allocator, based
> on the approach taken in the user virtual memory allocator.
> 
> This reduces the number of rbtree operations and linear traversals over
> the vmap extents to find a free area. The lazy vmap flushing makes this problem
> worse because because freed but not yet flushed vmaps tend to build up in
> the address space between flushes.
> 
> Steven noticed a performance problem with GFS2. Results are as follows...
> 

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
