Date: Mon, 7 May 2007 14:55:07 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Support concurrent local and remote frees and allocs on a slab.
In-Reply-To: <20070507145030.9b7f41bd.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0705071452080.10230@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0705042025520.29006@schroedinger.engr.sgi.com>
 <20070507145030.9b7f41bd.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Is there some way in which we can communicate this better?  It is quite
> central to maintainability.

Would you drop this patch again? I am still reworking it and you will get 
conflicts with the patchset I sent you.

> This change implies that "first_page" is no longer a "SLUB use".  Is that
> true?

We moved that into the huge page support functions in include/linux/mm.h
 
> I'm a bit surprised that slub didn't already have a per-cpu freelist of
> objects?

It does but it has a lock before and after access to per cpu slabs since
remove frees may access per cpu slabs. The patch splits the freelists.

> Each cache has this "cpu_slab" thing, which is not documented anywhere
> afaict.  What does it do, and how does this change enhance it?

It avoids the atomic overhead. If the cachelines are all hot then the 
atomic overhead and stack handling etc become a factor. I am minimizing 
that currently. Next rev will do that better.

> 	if (unlikely(node != -1 && page_to_nid(page) != node)) {
> 							
> get appropriately optimised away on non-NUMA?

Yes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
