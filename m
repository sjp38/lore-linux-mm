Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 4C9BB6B009F
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 10:04:12 -0400 (EDT)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MBX00IS4TQZNG90@mailout3.samsung.com> for
 linux-mm@kvack.org; Mon, 15 Oct 2012 23:04:11 +0900 (KST)
Received: from localhost.localdomain ([106.116.147.30])
 by mmp1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0MBX00JMCTQOCL70@mmp1.samsung.com> for linux-mm@kvack.org;
 Mon, 15 Oct 2012 23:04:10 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [RFC 0/2] DMA-mapping & IOMMU - physically contiguous allocations
Date: Mon, 15 Oct 2012 16:03:50 +0200
Message-id: <1350309832-18461-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Inki Dae <inki.dae@samsung.com>, Rob Clark <rob@ti.com>

Hello,

Some devices, which have IOMMU, for some use cases might require to
allocate a buffers for DMA which is contiguous in physical memory. Such
use cases appears for example in DRM subsystem when one wants to improve
performance or use secure buffer protection.

I would like to ask if adding a new attribute, as proposed in this RFC
is a good idea? I feel that it might be an attribute just for a single
driver, but I would like to know your opinion. Should we look for other
solution?

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center


Marek Szyprowski (2):
  common: DMA-mapping: add DMA_ATTR_FORCE_CONTIGUOUS attribute
  ARM: dma-mapping: add support for DMA_ATTR_FORCE_CONTIGUOUS attribute

 Documentation/DMA-attributes.txt |    9 +++++++++
 arch/arm/mm/dma-mapping.c        |   41 ++++++++++++++++++++++++++++++--------
 include/linux/dma-attrs.h        |    1 +
 3 files changed, 43 insertions(+), 8 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
