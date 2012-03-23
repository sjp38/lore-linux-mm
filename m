Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id A8B096B007E
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 08:26:11 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt2 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0M1C00CTK7VE8Q30@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 23 Mar 2012 12:26:02 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M1C009B47VJUC@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 23 Mar 2012 12:26:08 +0000 (GMT)
Date: Fri, 23 Mar 2012 13:26:01 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 0/2] ARM: dma-mapping: Fix mmap support for coherent buffers
In-reply-to: <08af01cd08ee$2fd04770$8f70d650$%szyprowski@samsung.com>
Message-id: <1332505563-17646-1-git-send-email-m.szyprowski@samsung.com>
References: <08af01cd08ee$2fd04770$8f70d650$%szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-samsung-soc@vger.kernel.org, iommu@lists.linux-foundation.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Joerg Roedel <joro@8bytes.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, KyongHo Cho <pullip.cho@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hiroshi Doyu <hdoyu@nvidia.com>, Subash Patel <subashrp@gmail.com>

Hello,

This patchset contains patches to fix broken mmap operation for memory
buffers allocated from 'dma_declare_coherent' pool after applying my dma
mapping redesign patches [1]. These issues have been reported by Subash
Patel.

[1] http://thread.gmane.org/gmane.linux.kernel.cross-arch/12819 

Patch summary:

Marek Szyprowski (2):
  common: add dma_mmap_from_coherent() function
  arm: dma-mapping: use dma_mmap_from_coherent()

 arch/arm/mm/dma-mapping.c          |    3 ++
 drivers/base/dma-coherent.c        |   42 ++++++++++++++++++++++++++++++++++++
 include/asm-generic/dma-coherent.h |    4 ++-
 3 files changed, 48 insertions(+), 1 deletions(-)

-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
