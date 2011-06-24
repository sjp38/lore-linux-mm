Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3C8A0900234
	for <linux-mm@kvack.org>; Fri, 24 Jun 2011 10:26:30 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: text/plain; charset=us-ascii
Received: from eu_spt1 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LNA0064DTG1PI70@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 24 Jun 2011 15:26:25 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LNA003NXTG0RW@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 24 Jun 2011 15:26:24 +0100 (BST)
Date: Fri, 24 Jun 2011 16:26:12 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: RE: [PATCH/RFC 0/8] ARM: DMA-mapping framework redesign
In-reply-to: <20110624091807.GC29299@8bytes.org>
Message-id: <001801cc327a$ab4b75f0$01e261d0$%szyprowski@samsung.com>
Content-language: pl
References: <1308556213-24970-1-git-send-email-m.szyprowski@samsung.com>
 <20110624091807.GC29299@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Joerg Roedel' <joro@8bytes.org>
Cc: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Arnd Bergmann' <arnd@arndb.de>, 'Russell King - ARM Linux' <linux@arm.linux.org.uk>, Marek Szyprowski <m.szyprowski@samsung.com>

Hello,

On Friday, June 24, 2011 11:18 AM Joerg Roedel wrote:

> On Mon, Jun 20, 2011 at 09:50:05AM +0200, Marek Szyprowski wrote:
> > This patch series is a continuation of my works on implementing generic
> > IOMMU support in DMA mapping framework for ARM architecture. Now I
> > focused on the DMA mapping framework itself. It turned out that adding
> > support for common dma_map_ops structure was not that hard as I initally
> > thought. After some modification most of the code fits really well to
> > the generic dma_map_ops methods.
> 
> I appreciate your progress on this generic dma_ops implementation. But
> for now it looks very ARM specific. Do you have plans to extend it to
> non-ARM iommu-api implementations too?

These works are just a first step to create an environment for real iommu 
& dma-mapping integration. It is much easier to work on IOMMU integration
once the dma-mapping operations can be easily changed for particular devices.
dma_map_ops gives such flexibility. It is also a de-facto standard interface
for other architectures so it was really desired to work on iommu
implementation on top of dma_map_ops.

Of course my patches will be ARM-centric, but I hope to isolate ARM-specific
from generic parts, which can be easily reused on other platforms. 

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
