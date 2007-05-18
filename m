Date: Fri, 18 May 2007 09:32:23 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc] increase struct page size?!
Message-ID: <20070518073223.GA23998@wotan.suse.de>
References: <20070518040854.GA15654@wotan.suse.de> <20070518001905.54cafeeb.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070518001905.54cafeeb.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, May 18, 2007 at 12:19:05AM -0700, Andrew Morton wrote:
> On Fri, 18 May 2007 06:08:54 +0200 Nick Piggin <npiggin@suse.de> wrote:
> 
> > Many batch operations on struct page are completely random,
> 
> But they shouldn't be: we should aim to place physically contiguous pages
> into logically contiguous pagecache slots, for all the reasons we
> discussed.

For big IO batch operations, pagecache would be more likely to be
physically contiguous, as would LRU, I suppose.

I'm more thinking of operations where things get reclaimed over time,
touched or dirtied in slightly different orderings, interleaved with
other allocations, etc.


> If/when that happens, there will be a *lot* of locality of reference
> against the pageframes in a lot of important codepaths.

And when it doesn't happen, we eat 75% more cache misses. And for that
matter we eat 75% more cache misses for non-batch operations like
allocating or freeing a page by slab, for example.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
