Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id D693C6B00EC
	for <linux-mm@kvack.org>; Wed, 18 Apr 2012 09:44:33 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt2 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0M2O003OPGUAGG10@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 18 Apr 2012 14:44:34 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M2O0005OGTZKV@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 18 Apr 2012 14:44:24 +0100 (BST)
Date: Wed, 18 Apr 2012 15:44:02 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCHv9 00/10] ARM: DMA-mapping framework redesign
Message-id: <1334756652-30830-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, iommu@lists.linux-foundation.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, KyongHo Cho <pullip.cho@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hiroshi Doyu <hdoyu@nvidia.com>, Subash Patel <subashrp@gmail.com>

Hello,

This is a quick update on dma-mapping redesign patches for ARM. I did
some minor fixes suggested by Arnd and extended commit messages for a
few patches. Like the previous version, the patches have been rebased 
onto latest Linux v3.4-rc3 which comes with dma_map_ops related
preparation changes.

The patches are also available on my git repository at:
git://git.linaro.org/people/mszyprowski/linux-dma-mapping.git 3.4-rc3-arm-dma-v9

The code has been tested on Samsung Exynos4 'UniversalC210' and NURI
boards with IOMMU driver posted by KyongHo Cho. The integration patch
has been posted in the following thread:
http://www.spinics.net/lists/arm-kernel/msg169030.html


History of the development:

v1: (initial version of the DMA-mapping redesign patches):
http://www.spinics.net/lists/linux-mm/msg21241.html

v2:
http://lists.linaro.org/pipermail/linaro-mm-sig/2011-September/000571.html
http://lists.linaro.org/pipermail/linaro-mm-sig/2011-September/000577.html

v3:
http://www.spinics.net/lists/linux-mm/msg25490.html

v4 and v5:
http://www.spinics.net/lists/arm-kernel/msg151147.html
http://www.spinics.net/lists/arm-kernel/msg154889.html

v6:
http://www.spinics.net/lists/linux-mm/msg29903.html

v7:
http://www.spinics.net/lists/arm-kernel/msg162149.html

v8:
http://www.spinics.net/lists/arm-kernel/msg168478.html

Best regards
Marek Szyprowski
Samsung Poland R&D Center


Patch summary:

Marek Szyprowski (10):
  common: add dma_mmap_from_coherent() function
  ARM: dma-mapping: use pr_* instread of printk
  ARM: dma-mapping: introduce DMA_ERROR_CODE constant
  ARM: dma-mapping: remove offset parameter to prepare for generic
    dma_ops
  ARM: dma-mapping: use asm-generic/dma-mapping-common.h
  ARM: dma-mapping: implement dma sg methods on top of any generic dma
    ops
  ARM: dma-mapping: move all dma bounce code to separate dma ops
    structure
  ARM: dma-mapping: remove redundant code and cleanup
  ARM: dma-mapping: use alloc, mmap, free from dma_ops
  ARM: dma-mapping: add support for IOMMU mapper

 arch/arm/Kconfig                   |    9 +
 arch/arm/common/dmabounce.c        |   84 +++-
 arch/arm/include/asm/device.h      |    4 +
 arch/arm/include/asm/dma-iommu.h   |   34 ++
 arch/arm/include/asm/dma-mapping.h |  407 ++++-----------
 arch/arm/mm/dma-mapping.c          | 1015 ++++++++++++++++++++++++++++++------
 arch/arm/mm/vmregion.h             |    2 +-
 drivers/base/dma-coherent.c        |   42 ++
 include/asm-generic/dma-coherent.h |    4 +-
 9 files changed, 1134 insertions(+), 467 deletions(-)
 create mode 100644 arch/arm/include/asm/dma-iommu.h

-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
