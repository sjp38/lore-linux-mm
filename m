Date: Tue, 7 May 2002 15:10:57 +0100
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [RFC][PATCH] dcache and rmap
Message-ID: <20020507151057.A6543@infradead.org>
References: <200205052117.16268.tomlins@cam.org> <20020507014414.GL15756@holomorphy.com> <200205070741.52896.tomlins@cam.org> <20020507125712.GM15756@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20020507125712.GM15756@holomorphy.com>; from wli@holomorphy.com on Tue, May 07, 2002 at 05:57:12AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, Ed Tomlinson <tomlins@cam.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 07, 2002 at 05:57:12AM -0700, William Lee Irwin III wrote:
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

<hint>
In newer Solaris versions (at least SunOS 5.7/5.8) kmem_cache_t has a new
method to allow reclaiming of objects on memory pressure.
</hint>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
