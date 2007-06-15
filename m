Date: Fri, 15 Jun 2007 07:39:54 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] slob: poor man's NUMA, take 5.
In-Reply-To: <20070615082237.GA29917@linux-sh.org>
Message-ID: <Pine.LNX.4.64.0706150737190.7471@schroedinger.engr.sgi.com>
References: <20070615033412.GA28687@linux-sh.org> <20070615064445.GM11115@waste.org>
 <20070615082237.GA29917@linux-sh.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>
Cc: Matt Mackall <mpm@selenic.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 15 Jun 2007, Paul Mundt wrote:

> + * %GFP_DMA - Allocation suitable for DMA.
> + *
> + * %GFP_DMA32 - Large allocation suitable for DMA (depending on platform).

GFP_DMA32 is not supported in the slab allocators.

GFP_DMA should only be used for kmalloc caches. Otherwise use a slab 
created with SLAB_DMA.

> + *
> + * %__GFP_ZERO - Zero the allocation on success.
> + *

__GFP_ZERO is not support for slab allocations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
