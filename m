Date: Wed, 14 Feb 2007 20:09:16 -0600
From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH 2/7] Add PageMlocked() page state bit and lru infrastructure
Message-ID: <20070215020916.GS10108@waste.org>
References: <20070215012449.5343.22942.sendpatchset@schroedinger.engr.sgi.com> <20070215012459.5343.72021.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070215012459.5343.72021.sendpatchset@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, Christoph Hellwig <hch@infradead.org>, Arjan van de Ven <arjan@infradead.org>, Nigel Cunningham <nigel@nigel.suspend2.net>, "Martin J. Bligh" <mbligh@mbligh.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Feb 14, 2007 at 05:24:59PM -0800, Christoph Lameter wrote:
> Add PageMlocked() infrastructure
> 
> This adds a new PG_mlocked to mark pages that were taken off the LRU
> because they have a reference from a VM_LOCKED vma.
> 
> (Yes, we still have 4 free page flag bits.... BITS_PER_LONG-FLAGS_RESERVED =
> 32 - 9 = 23 page flags).
> 
> Also add pagevec handling for returning mlocked pages to the LRU.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> Index: linux-2.6.20/include/linux/page-flags.h
> ===================================================================
> --- linux-2.6.20.orig/include/linux/page-flags.h	2007-02-14 15:47:13.000000000 -0800
> +++ linux-2.6.20/include/linux/page-flags.h	2007-02-14 16:00:40.000000000 -0800
> @@ -91,6 +91,7 @@
>  #define PG_nosave_free		18	/* Used for system suspend/resume */
>  #define PG_buddy		19	/* Page is free, on buddy lists */
>  
> +#define PG_mlocked		20	/* Page is mlocked */

I think we should be much more precise in documenting the semantics of
these bits. This particular comment is imprecise enough to be
incorrect. This bit being set indicates that we saw that it was
mlocked at some point in the past, not any guarantee that it's mlocked
now. And the same for the converse.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
