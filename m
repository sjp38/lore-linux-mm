Date: Tue, 3 Oct 2006 14:36:58 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] page_alloc: fix kernel-doc and func. declaration
In-Reply-To: <20061003141445.0c502d45.rdunlap@xenotime.net>
Message-ID: <Pine.LNX.4.64.0610031435590.22775@schroedinger.engr.sgi.com>
References: <20061003141445.0c502d45.rdunlap@xenotime.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <rdunlap@xenotime.net>
Cc: linux-mm@kvack.org, akpm <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Oct 2006, Randy Dunlap wrote:

>  /**
>   * set_dma_reserve - Account the specified number of pages reserved in ZONE_DMA
> - * @new_dma_reserve - The number of pages to mark reserved
> + * @new_dma_reserve: The number of pages to mark reserved
>   *
>   * The per-cpu batchsize and zone watermarks are determined by present_pages.
>   * In the DMA zone, a significant percentage may be consumed by kernel image
>   * and other unfreeable allocations which can skew the watermarks badly. This
>   * function may optionally be used to account for unfreeable pages in
> - * ZONE_DMA. The effect will be lower watermarks and smaller per-cpu batchsize
> + * ZONE_DMA. The effect will be lower watermarks and smaller per-cpu batchsize.
>   */
>  void __init set_dma_reserve(unsigned long new_dma_reserve)

Hmmm. With the optional ZONE_DMA patch this becomes a reservation in the 
first zone, which may be ZONE_NORMAL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
