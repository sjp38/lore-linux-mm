Date: Mon, 23 Jul 2007 16:00:24 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] add __GFP_ZERP to GFP_LEVEL_MASK
In-Reply-To: <20070723155603.f1b1a735.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0707231558590.32630@schroedinger.engr.sgi.com>
References: <1185185020.8197.11.camel@twins> <20070723113712.c0ee29e5.akpm@linux-foundation.org>
 <1185216048.5535.1.camel@lappy> <20070723144323.1ac34b16@schroedinger.engr.sgi.com>
 <20070723151306.86e3e0ce.akpm@linux-foundation.org>
 <alpine.LFD.0.999.0707231539520.3607@woody.linux-foundation.org>
 <20070723155603.f1b1a735.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel <linux-kernel@vger.kernel.org>, Daniel Phillips <phillips@google.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Jul 2007, Andrew Morton wrote:

> So this:
> 
> 	/*
> 	 * Be lazy and only check for valid flags here,  keeping it out of the
> 	 * critical path in kmem_cache_alloc().
> 	 */
> 	BUG_ON(flags & ~(GFP_DMA | __GFP_ZERO | GFP_LEVEL_MASK));
> 
> would no longer need the __GFP_ZERO.  Ditto in slob's new_slab().

That __GFP_ZERO is needed to avoid triggering the BUG_ON. The next line

	local_flags = (flags & GFP_LEVEL_MASK);

filters out the __GFP_ZERO before calling the page allocator.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
