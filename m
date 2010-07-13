Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 178BC6B02A8
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 04:31:29 -0400 (EDT)
Date: Tue, 13 Jul 2010 17:30:43 +0900
Subject: Re: [RFC 3/3] mm: iommu: The Virtual Contiguous Memory Manager
From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
In-Reply-To: <20100713092012.7c1fe53e@lxorguk.ukuu.org.uk>
References: <4C3BFDD3.8040209@codeaurora.org>
	<20100713145852C.fujita.tomonori@lab.ntt.co.jp>
	<20100713092012.7c1fe53e@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-Id: <20100713173028M.fujita.tomonori@lab.ntt.co.jp>
Sender: owner-linux-mm@kvack.org
To: alan@lxorguk.ukuu.org.uk
Cc: fujita.tomonori@lab.ntt.co.jp, zpfeffer@codeaurora.org, joro@8bytes.org, dwalker@codeaurora.org, andi@firstfloor.org, randy.dunlap@oracle.com, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Tue, 13 Jul 2010 09:20:12 +0100
Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:

> > Why video4linux can't use the DMA API? Doing DMA with vmalloc'ed
> > buffers is a thing that we should avoid (there are some exceptions
> > like xfs though).
> 
> Vmalloc is about the only API for creating virtually linear memory areas.
> The video stuff really needs that to avoid lots of horrible special cases
> when doing buffer processing and the like.
> 
> Pretty much each driver using it has a pair of functions 'rvmalloc' and
> 'rvfree' so given a proper "vmalloc_for_dma()" type interface can easily
> be switched

We already have helper functions for DMA with vmap pages,
flush_kernel_vmap_range and invalidate_kernel_vmap_range.

I think that the current DMA API with the above helper functions
should work well drivers that want virtually linear large memory areas
(such as xfs).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
