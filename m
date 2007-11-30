Date: Fri, 30 Nov 2007 11:14:01 +0200 (EET)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [PATCH] Fix kmem_cache_free performance regression in slab
In-Reply-To: <20071129184539.ba6342b8.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0711301110540.28494@sbz-30.cs.Helsinki.FI>
References: <20071129190513.GD2584@parisc-linux.org>
 <20071129184539.ba6342b8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <matthew@wil.cx>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 29 Nov 2007 12:05:13 -0700 Matthew Wilcox <matthew@wil.cx> wrote:
> > The database performance group have found that half the cycles spent
> > in kmem_cache_free are spent in this one call to BUG_ON.  Moving it
> > into the CONFIG_SLAB_DEBUG-only function cache_free_debugcheck() is a
> > performance win of almost 0.5% on their particular benchmark.
> > 
> > The call was added as part of commit ddc2e812d592457747c4367fb73edcaa8e1e49ff
> > with the comment that "overhead should be minimal".  It may have been
> > minimal at the time, but it isn't now.
> > 

On Thu, 29 Nov 2007, Andrew Morton wrote:
> It is worth noting that the offending commit hit mainline in June 2006.
> 
> It takes a very long time for some performance regressions to be
> discovered.  By which time it is effectively too late to fix it.

What architecture is this? x86_64? I don't think the BUG_ON per se caused 
the performance regression but rather the virt_to_head_page() changes to 
virt_to_cache() that were added later. But reverting the BUG_ON is fine by 
me.

Thanks Matthew and others for tracking this down!

				Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
