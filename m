Date: Sun, 28 Oct 2007 15:12:29 +0200 (EET)
From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: Re: [patch 07/10] SLUB: Avoid referencing kmem_cache structure in
 __slab_alloc
In-Reply-To: <20071028033259.992768446@sgi.com>
Message-ID: <Pine.LNX.4.64.0710281512160.6766@sbz-30.cs.Helsinki.FI>
References: <20071028033156.022983073@sgi.com> <20071028033259.992768446@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Matthew Wilcox <matthew@wil.cx>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 27 Oct 2007, Christoph Lameter wrote:
> There is the need to use the objects per slab in the first part of
> __slab_alloc() which is still pretty hot. Copy the number of objects
> per slab into the kmem_cache_cpu structure. That way we can get the
> value from a cache line that we already need to touch. This brings
> the kmem_cache_cpu structure up to 4 even words.

Reviewed-by: Pekka Enberg <penberg@cs.helsinki.fi>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
