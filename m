Received: from midway.site ([71.117.236.95]) by xenotime.net for <linux-mm@kvack.org>; Tue, 3 Oct 2006 15:48:23 -0700
Date: Tue, 3 Oct 2006 15:49:49 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH] page_alloc: fix kernel-doc and func. declaration
Message-Id: <20061003154949.7953c6f9.rdunlap@xenotime.net>
In-Reply-To: <Pine.LNX.4.64.0610031435590.22775@schroedinger.engr.sgi.com>
References: <20061003141445.0c502d45.rdunlap@xenotime.net>
	<Pine.LNX.4.64.0610031435590.22775@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, akpm <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Tue, 3 Oct 2006 14:36:58 -0700 (PDT) Christoph Lameter wrote:

> On Tue, 3 Oct 2006, Randy Dunlap wrote:
> 
> >  /**
> >   * set_dma_reserve - Account the specified number of pages reserved in ZONE_DMA
> > - * @new_dma_reserve - The number of pages to mark reserved
> > + * @new_dma_reserve: The number of pages to mark reserved
> >   *
> >   * The per-cpu batchsize and zone watermarks are determined by present_pages.
> >   * In the DMA zone, a significant percentage may be consumed by kernel image
> >   * and other unfreeable allocations which can skew the watermarks badly. This
> >   * function may optionally be used to account for unfreeable pages in
> > - * ZONE_DMA. The effect will be lower watermarks and smaller per-cpu batchsize
> > + * ZONE_DMA. The effect will be lower watermarks and smaller per-cpu batchsize.
> >   */
> >  void __init set_dma_reserve(unsigned long new_dma_reserve)
> 
> Hmmm. With the optional ZONE_DMA patch this becomes a reservation in the 
> first zone, which may be ZONE_NORMAL.

I didn't change any of that wording.  Do you want to change it?
do you want me to make that change?  or what?

thanks,
---
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
