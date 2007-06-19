Date: Tue, 19 Jun 2007 16:00:11 -0500
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [patch 05/26] Slab allocators: Cleanup zeroing allocations
Message-ID: <20070619210010.GN11166@waste.org>
References: <20070618095838.238615343@sgi.com> <20070618095914.622685354@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070618095914.622685354@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

On Mon, Jun 18, 2007 at 02:58:43AM -0700, clameter@sgi.com wrote:
> It becomes now easy to support the zeroing allocs with generic inline functions
> in slab.h. Provide inline definitions to allow the continued use of
> kzalloc, kmem_cache_zalloc etc but remove other definitions of zeroing functions
> from the slab allocators and util.c.

The SLOB bits up through here look fine.

I worry a bit about adding another branch checking __GFP_ZERO in such
a hot path for SLAB/SLUB.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
