Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 1804890013C
	for <linux-mm@kvack.org>; Fri,  2 Sep 2011 09:53:29 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt2 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0LQW00GTTEL0HK20@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 02 Sep 2011 14:53:24 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LQW00JA6EL0J9@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 02 Sep 2011 14:53:24 +0100 (BST)
Date: Fri, 02 Sep 2011 15:53:12 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH/RFC 0/8 v2] ARM: DMA-mapping framework redesign
Message-id: <1314971599-14428-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>

Hello,

This is a snapshot of my work-in-progress on DMA-mapping framework
redesign. All these works are a preparation for adding support for IOMMU
controllers.

DMA-mapping patches have been rebased onto Linux v3.1-rc4 kernel, what
required resolving a bunch of confilcts in the code. The patches have
been heavily tested and all bugs found in the initial version have been
fixed.

Here is the link to the initial version of the DMA-mapping redesign patches:
http://www.spinics.net/lists/linux-mm/msg21241.html

TODO: 
- merge the patches with CMA patches and respective changes in
  DMA-mapping framework
- start the discussion about chaning alloc_coherent into alloc_attrs in
dma_map_ops structure.

The proof-of-concept IOMMU mapper for DMA-mapping will follow. In next 2
weeks I will be on holidays, so I decided not to delay these patch
anymore longer.

Best regards
--
Marek Szyprowski
Samsung Poland R&D Center


Patch summary:

Marek Szyprowski (7):
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

 arch/arm/Kconfig                   |    1 +
 arch/arm/common/dmabounce.c        |   78 ++++++--
 arch/arm/include/asm/device.h      |    1 +
 arch/arm/include/asm/dma-mapping.h |  401 ++++++++++--------------------------
 arch/arm/mm/dma-mapping.c          |  269 +++++++++++++-----------
 include/linux/dma-attrs.h          |    1 +
 include/linux/dma-mapping.h        |   13 +-
 7 files changed, 325 insertions(+), 439 deletions(-)

-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
