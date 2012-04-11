Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 691986B004A
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 08:07:53 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=us-ascii
Received: from euspt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0M2B001BCDP9S100@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 11 Apr 2012 13:07:57 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M2B00NM6DP327@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 11 Apr 2012 13:07:51 +0100 (BST)
Date: Wed, 11 Apr 2012 14:07:48 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCHv8 05/10] ARM: dma-mapping: use
 asm-generic/dma-mapping-common.h
In-reply-to: <201204101147.20733.arnd@arndb.de>
Message-id: <012f01cd17db$b5f918d0$21eb4a70$%szyprowski@samsung.com>
Content-language: pl
References: <1334055852-19500-1-git-send-email-m.szyprowski@samsung.com>
 <1334055852-19500-6-git-send-email-m.szyprowski@samsung.com>
 <201204101147.20733.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Arnd Bergmann' <arnd@arndb.de>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, iommu@lists.linux-foundation.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Joerg Roedel' <joro@8bytes.org>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, 'Chunsang Jeong' <chunsang.jeong@linaro.org>, 'Krishna Reddy' <vdumpa@nvidia.com>, 'KyongHo Cho' <pullip.cho@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, 'Benjamin Herrenschmidt' <benh@kernel.crashing.org>, 'Konrad Rzeszutek Wilk' <konrad.wilk@oracle.com>, 'Hiroshi Doyu' <hdoyu@nvidia.com>, 'Subash Patel' <subashrp@gmail.com>

Hi Arnd,

On Tuesday, April 10, 2012 1:47 PM Arnd Bergmann wrote:

> On Tuesday 10 April 2012, Marek Szyprowski wrote:
> > This patch modifies dma-mapping implementation on ARM architecture to
> > use common dma_map_ops structure and asm-generic/dma-mapping-common.h
> > helpers.
> >
> > Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> > Acked-by: Kyungmin Park <kyungmin.park@samsung.com>
> > ---
> >  arch/arm/Kconfig                   |    1 +
> >  arch/arm/include/asm/device.h      |    1 +
> >  arch/arm/include/asm/dma-mapping.h |  196 +++++-------------------------------
> >  arch/arm/mm/dma-mapping.c          |  148 ++++++++++++++++-----------
> >  4 files changed, 115 insertions(+), 231 deletions(-)
> 
> Looks good in principle. One question: Now that many of the functions are only
> used in the dma_map_ops, can you make them 'static' instead?

Some of these non static functions (mainly arm_dma_*_sg_* family) are also used by dma bounce
code introduced in the next patch, that's why I left them without static attribute.

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
