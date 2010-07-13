Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9E3B46B02A8
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 04:12:42 -0400 (EDT)
Date: Tue, 13 Jul 2010 09:20:12 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [RFC 3/3] mm: iommu: The Virtual Contiguous Memory Manager
Message-ID: <20100713092012.7c1fe53e@lxorguk.ukuu.org.uk>
In-Reply-To: <20100713145852C.fujita.tomonori@lab.ntt.co.jp>
References: <4C2D965F.5000206@codeaurora.org>
	<20100710145639.GC10080@8bytes.org>
	<4C3BFDD3.8040209@codeaurora.org>
	<20100713145852C.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: zpfeffer@codeaurora.org, joro@8bytes.org, dwalker@codeaurora.org, andi@firstfloor.org, randy.dunlap@oracle.com, mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-msm@vger.kernel.org, linux-omap@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

> Why video4linux can't use the DMA API? Doing DMA with vmalloc'ed
> buffers is a thing that we should avoid (there are some exceptions
> like xfs though).

Vmalloc is about the only API for creating virtually linear memory areas.
The video stuff really needs that to avoid lots of horrible special cases
when doing buffer processing and the like.

Pretty much each driver using it has a pair of functions 'rvmalloc' and
'rvfree' so given a proper "vmalloc_for_dma()" type interface can easily
be switched

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
