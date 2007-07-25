Date: Wed, 25 Jul 2007 14:06:49 +0100
Subject: Re: [PATCH] add __GFP_ZERO to GFP_LEVEL_MASK
Message-ID: <20070725130649.GC32445@skynet.ie>
References: <1185185020.8197.11.camel@twins> <20070723112143.GB19437@skynet.ie> <1185190711.8197.15.camel@twins> <Pine.LNX.4.64.0707231615310.427@schroedinger.engr.sgi.com> <1185256869.8197.27.camel@twins> <Pine.LNX.4.64.0707240007100.3128@schroedinger.engr.sgi.com> <1185261894.8197.33.camel@twins> <Pine.LNX.4.64.0707240030110.3295@schroedinger.engr.sgi.com> <20070724120751.401bcbcb@schroedinger.engr.sgi.com> <20070724122542.d4ac734a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20070724122542.d4ac734a.akpm@linux-foundation.org>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, Daniel Phillips <phillips@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On (24/07/07 12:25), Andrew Morton didst pronounce:
> On Tue, 24 Jul 2007 12:07:51 -0700
> Christoph Lameter <clameter@sgi.com> wrote:
> 
> > Then there are some other flags. I am wondering why they are in
> > GFP_LEVEL_MASK?
> > 
> > __GFP_COLD	Does not make sense for slab allocators since we have
> > 		to touch the page immediately.
> > 
> > __GFP_COMP	No effect. Added by the page allocator on their own
> > 		if a higher order allocs are used for a slab.
> > 
> > __GFP_MOVABLE	The movability of a slab is determined by the
> > 		options specified at kmem_cache_create time. If this is
> > 		specified at kmalloc time then we will have some random
> > 		slabs movable and others not. 
> 
> Yes, they seem inappropriate.  Especially the first two.

And the third one is also inappropriate by the definition of GFP_LEVEL_MASK
Christoph is using. If GFP_LEVEL_MASK is to be used to filter out flags
that are unsuitable for higher allocators such as slab and vmalloc, then
they shouldn't be using __GFP_MOVABLE because they are unlikely to do the
correct thing with the pages.

When the flags were added, I was treating GFP_LEVEL_MASK as a set of
allowed flags to the allocator.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
