Date: Sat, 9 Feb 2008 14:35:18 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: SLUB tbench regression due to page allocator deficiency
Message-Id: <20080209143518.ced71a48.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0802091332450.12965@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0802091332450.12965@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Pekka J Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Sat, 9 Feb 2008 13:45:11 -0800 (PST) Christoph Lameter <clameter@sgi.com> wrote:

> Isnt there a way that we can make the page allocator handle PAGE_SIZEd 
> allocations in such a way that is competitive with the slab allocators? 
> The cycle count for an allocation needs to be <100 not just below 1000 as 
> it is now.
> 

Well.  Where are the cycles spent?

We are notorious for sucking but I don't think even we suck enough to have
left a 10x optimisation opportunity in the core page allocator ;)

>  include/linux/slub_def.h |    6 +++---
>  mm/slub.c                |   25 +++++++++++++++++--------

I am worrried by a patch which squeezes a few percent out of tbench.  Does
it improve real things?  Does anything regress?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
