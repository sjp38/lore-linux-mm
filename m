Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 32E3E6B02A8
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 04:34:23 -0400 (EDT)
Date: Tue, 13 Jul 2010 09:42:44 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [RFC 3/3] mm: iommu: The Virtual Contiguous Memory Manager
Message-ID: <20100713094244.7eb84f1b@lxorguk.ukuu.org.uk>
In-Reply-To: <20100713173028M.fujita.tomonori@lab.ntt.co.jp>
References: <4C3BFDD3.8040209@codeaurora.org>
	<20100713145852C.fujita.tomonori@lab.ntt.co.jp>
	<20100713092012.7c1fe53e@lxorguk.ukuu.org.uk>
	<20100713173028M.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: zpfeffer@codeaurora.org, joro@8bytes.org, dwalker@codeaurora.org, andi@firstfloor.org, randy.dunlap@oracle.com, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Tue, 13 Jul 2010 17:30:43 +0900
FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp> wrote:

> On Tue, 13 Jul 2010 09:20:12 +0100
> Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
> 
> > > Why video4linux can't use the DMA API? Doing DMA with vmalloc'ed
> > > buffers is a thing that we should avoid (there are some exceptions
> > > like xfs though).
> > 
> > Vmalloc is about the only API for creating virtually linear memory areas.
> > The video stuff really needs that to avoid lots of horrible special cases
> > when doing buffer processing and the like.
> > 
> > Pretty much each driver using it has a pair of functions 'rvmalloc' and
> > 'rvfree' so given a proper "vmalloc_for_dma()" type interface can easily
> > be switched
> 
> We already have helper functions for DMA with vmap pages,
> flush_kernel_vmap_range and invalidate_kernel_vmap_range.

I'm not sure they help at all because the DMA user for these pages isn't
the video driver - it's the USB layer, and the USB layer isn't
specifically aware it is being passed vmap pages.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
