From: Nikita Danilov <Nikita@Namesys.COM>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <15583.40551.778094.604938@laputa.namesys.com>
Date: Mon, 13 May 2002 15:07:19 +0400
Subject: Re: [RFC][PATCH] dcache and rmap
In-Reply-To: <20020507125712.GM15756@holomorphy.com>
References: <200205052117.16268.tomlins@cam.org>
	<20020507014414.GL15756@holomorphy.com>
	<200205070741.52896.tomlins@cam.org>
	<20020507125712.GM15756@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Ed Tomlinson <tomlins@cam.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III writes:
 > At some point in the past, I wrote:
 > >> In short, I don't think you went far enough. How do you feel about
 > >> GFP_SPECULATIVE (a.k.a. GFP_DONT_TRY_TOO_HARD), cache priorities and
 > >> cache shrinking drivers?
 > 
 > On Tue, May 07, 2002 at 07:41:52AM -0400, Ed Tomlinson wrote:
 > > Think I will sprinkle slab.c with a printk or two to see if we detect when
 > > it's allocations are eating other caches.  If this works we should be able to
 > > let the vm know when to shrink the slab cache and to let it know which
 > > caches need shrinking (ie shrink_caches becomes a 'driver' to shrink the
 > > dcache/icache family.  kmem_cache_reap being the generic 'driver')
 > > Thanks for the feedback and interesting idea,
 > 
 > Well, the trick is kmem_cache_reap() doesn't know how to prune
 > references to things within the cache like prune_dcache() does. It is
 > in essence its own cache in front of another cache for allocations. I'm
 > not sure making kmem_cache_reap() trigger reaping of the caches it's
 > parked in front of is a great idea. It seems that it would go the other
 > direction: reaping a cache parked in front of a slab would want to call
 > kmem_cache_reap() sometime afterward (so the memory is actually
 > reclaimed instead of sitting in the slab cache). IIRC the VM actually
 > does this at some point after calling the assorted cache shrink functions.
 > kmem_cache_reap() may well be needed in contexts where the caches are
 > doing fine jobs of keeping their space under control or shrinking
 > themselves just fine, without intervention from outside callers.

I remember Linus once mentioned an idea that slab pages should have
->writepage() that triggers shrink of the front-end cache.

Along this way, VM would just manage one big cache---physical memory.

 > 
 > 
 > Cheers,
 > Bill

Nikita.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
