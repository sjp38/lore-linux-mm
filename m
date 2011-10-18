Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 99EEC6B002C
	for <linux-mm@kvack.org>; Tue, 18 Oct 2011 13:19:41 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt2 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LT900E2ZUSPGV80@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 18 Oct 2011 18:19:38 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LT900MY1USPUV@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 18 Oct 2011 18:19:37 +0100 (BST)
Date: Tue, 18 Oct 2011 19:19:17 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 0/8 v3] ARM: DMA-mapping framework redesign
Message-id: <1318958365-19120-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>

Hello,

This is another update on my attempt on DMA-mapping framework redesign.
I focused mainly on the IOMMU mapper for ARM DMA-mapping implementation.
DMA-mapping patches have been rebased onto Linux v3.1-rc9-next kernel
with CMA v16 patches already applied. I've also integrated the code
provided by Krishna Reddy and added the missing methods for IOMMU DMA
mapper. The code has been tested on Samsung Exynos4 board.

Here is the link to the initial version of the DMA-mapping redesign patches:
http://www.spinics.net/lists/linux-mm/msg21241.html

Second version of the patches:
http://lists.linaro.org/pipermail/linaro-mm-sig/2011-September/000571.html
http://lists.linaro.org/pipermail/linaro-mm-sig/2011-September/000577.html

TODO:
- start the discussion about chaning alloc_coherent into alloc_attrs in
dma_map_ops structure.

GIT tree will all the patches:
http://git.infradead.org/users/kmpark/linux-2.6-samsung/shortlog/refs/heads/dma-mapping-v4
git://git.infradead.org/users/kmpark/linux-2.6-samsung dma-mapping-v4

Best regards
--
Marek Szyprowski
Samsung Poland R&D Center


Patch summary:
Marek Szyprowski (8):
  ARM: dma-mapping: remove offset parameter to prepare for generic
    dma_ops
  ARM: dma-mapping: use asm-generic/dma-mapping-common.h
  ARM: dma-mapping: implement dma sg methods on top of any generic dma
    ops
  ARM: dma-mapping: move all dma bounce code to separate dma ops
    structure
  ARM: dma-mapping: remove redundant code and cleanup
  common: dma-mapping: change alloc/free_coherent method to more
    generic alloc/free_attrs
  ARM: dma-mapping: use alloc, mmap, free from dma_ops
  ARM: dma-mapping: add support for IOMMU mapper

 arch/arm/Kconfig                   |    9 +
 arch/arm/common/dmabounce.c        |   78 +++-
 arch/arm/include/asm/device.h      |    5 +
 arch/arm/include/asm/dma-iommu.h   |   35 ++
 arch/arm/include/asm/dma-mapping.h |  403 +++++------------
 arch/arm/mm/dma-mapping.c          |  869 +++++++++++++++++++++++++++++++-----
 arch/arm/mm/vmregion.h             |    2 +-
 include/linux/dma-attrs.h          |    1 +
 include/linux/dma-mapping.h        |   13 +-
 9 files changed, 973 insertions(+), 442 deletions(-)
 create mode 100644 arch/arm/include/asm/dma-iommu.h

-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
