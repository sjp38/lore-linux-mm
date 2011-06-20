Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id BFC716B010B
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 11:23:29 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=us-ascii
Received: from eu_spt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LN3008F2HF2VY10@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 20 Jun 2011 16:23:26 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LN3002RUHF17F@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 20 Jun 2011 16:23:25 +0100 (BST)
Date: Mon, 20 Jun 2011 17:23:22 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCH 4/8] ARM: dma-mapping: implement dma sg methods on top of
 generic dma ops
In-reply-to: <20110620144012.GE26089@n2100.arm.linux.org.uk>
Message-id: <000801cc2f5d$fdd720a0$f98561e0$%szyprowski@samsung.com>
Content-language: pl
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com>
 <1308556213-24970-5-git-send-email-m.szyprowski@samsung.com>
 <20110620144012.GE26089@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Russell King - ARM Linux' <linux@arm.linux.org.uk>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Arnd Bergmann' <arnd@arndb.de>, 'Joerg Roedel' <joro@8bytes.org>, Marek Szyprowski <m.szyprowski@samsung.com>

Hello,

On Monday, June 20, 2011 4:40 PM Russell King - ARM Linux wrote:

> On Mon, Jun 20, 2011 at 09:50:09AM +0200, Marek Szyprowski wrote:
> > This patch converts all dma_sg methods to be generic (independent of the
> > current DMA mapping implementation for ARM architecture). All dma sg
> > operations are now implemented on top of respective
> > dma_map_page/dma_sync_single_for* operations from dma_map_ops structure.
> 
> No.  We really don't want to do this.

I assume you want to keep the current design for performance reasons?

It's really not a problem for me. I can change my patches to keep 
arm_dma_*_sg_* functions and create some stubs for dmabounce version.

> If we want to move the dsb() out of the mapping functions (which I
> have a patch for) to avoid doing a dsb() on each and every sg segment,
> then we must not use the generic stuff.

Ok, specialized (optimized) version of dma_*_sg_* operations are definitely
better. The current version just calls respective dma_single_* operations in
a loop, so in my patches I decided to create some generic version just to
simplify the code. 

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
