Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id CDE579000BD
	for <linux-mm@kvack.org>; Mon, 20 Jun 2011 11:15:49 -0400 (EDT)
Received: from spt2.w1.samsung.com (mailout1.w1.samsung.com [210.118.77.11])
 by mailout1.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LN3009DTH2BCE@mailout1.w1.samsung.com> for linux-mm@kvack.org;
 Mon, 20 Jun 2011 16:15:47 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LN300COQH2AOA@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 20 Jun 2011 16:15:46 +0100 (BST)
Date: Mon, 20 Jun 2011 17:15:43 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCH 2/8] ARM: dma-mapping: implement dma_map_single on top of
 dma_map_page
In-reply-to: <20110620143911.GD26089@n2100.arm.linux.org.uk>
Message-id: <000101cc2f5c$ec21da40$c4658ec0$%szyprowski@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-language: pl
Content-transfer-encoding: 7BIT
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com>
 <1308556213-24970-3-git-send-email-m.szyprowski@samsung.com>
 <20110620143911.GD26089@n2100.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Russell King - ARM Linux' <linux@arm.linux.org.uk>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Arnd Bergmann' <arnd@arndb.de>, 'Joerg Roedel' <joro@8bytes.org>, Marek Szyprowski <m.szyprowski@samsung.com>

Hello,

On Monday, June 20, 2011 4:39 PM Russell King - ARM Linux wrote:

> On Mon, Jun 20, 2011 at 09:50:07AM +0200, Marek Szyprowski wrote:
> > This patch consolidates dma_map_single and dma_map_page calls. This is
> > required to let dma-mapping framework on ARM architecture use common,
> > generic dma-mapping helpers.
> 
> This breaks DMA API debugging, which requires that dma_map_page and
> dma_unmap_page are paired separately from dma_map_single and
> dma_unmap_single().

Ok, right. This can be fixed by creating appropriate static inline functions
in dma-mapping.h and moving dma_debug_* calls there. These function will be
later removed by using dma_map_ops and include/asm-generic/dma-mapping-common.h
inlines, which do all the dma_debug_* calls correctly anyway. 

> This also breaks dmabounce when used with a highmem-enabled system -
> dmabounce refuses the dma_map_page() API but allows the dma_map_single()
> API.

I really not sure how this change will break dma bounce code. 

Does it mean that it is allowed to call dma_map_single() on kmapped HIGH_MEM 
page?

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
