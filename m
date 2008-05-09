Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.8/8.13.8) with ESMTP id m49H1Dao091006
	for <linux-mm@kvack.org>; Fri, 9 May 2008 17:01:13 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m49H1CmA2838688
	for <linux-mm@kvack.org>; Fri, 9 May 2008 19:01:12 +0200
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m49H1C5G016097
	for <linux-mm@kvack.org>; Fri, 9 May 2008 19:01:12 +0200
Date: Fri, 9 May 2008 19:01:11 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [PATCH] sparsemem vmemmap: initialize memmap.
Message-ID: <20080509170111.GA7248@osiris.boeblingen.de.ibm.com>
References: <20080509063856.GC9840@osiris.boeblingen.de.ibm.com> <Pine.LNX.4.64.0805090923550.18195@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0805090923550.18195@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Whitcroft <apw@shadowen.org>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 09, 2008 at 09:25:41AM -0700, Christoph Lameter wrote:
> Nack. vmemmap_alloc_block does 
> 
> void * __meminit vmemmap_alloc_block(unsigned long size, int node)
> {
>         /* If the main allocator is up use that, fallback to bootmem. */
>         if (slab_is_available()) {
>                 struct page *page = alloc_pages_node(node,
>                                 GFP_KERNEL | __GFP_ZERO, get_order(size));
>                 if (page)
>                         return page_address(page);
>                 return NULL;
>         } else
>                 return __earlyonly_bootmem_alloc(node, size, size,
>                                 __pa(MAX_DMA_ADDRESS));
> }
> 
> memory is always zeroed. Maybe you use an alternate implementation that is 
> broken?

Yes, I missed the __GFP_ZERO. Already figured out and fixed in arch code.

Thanks ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
