Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id D097A6B00E8
	for <linux-mm@kvack.org>; Fri, 13 Apr 2012 10:06:06 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt2 ([210.118.77.13]) by mailout3.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0M2F00JTR8HGTO10@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 13 Apr 2012 15:05:40 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M2F00GXB8I0DZ@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 13 Apr 2012 15:06:00 +0100 (BST)
Date: Fri, 13 Apr 2012 16:05:46 +0200
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 0/4] ARM: replace custom consistent dma region with vmalloc
Message-id: <1334325950-7881-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Chunsang Jeong <chunsang.jeong@linaro.org>, Krishna Reddy <vdumpa@nvidia.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Hiroshi Doyu <hdoyu@nvidia.com>, Subash Patel <subashrp@gmail.com>

Hi!

Recent changes to ioremap and unification of vmalloc regions on ARM
significantly reduces the possible size of the consistent dma region and
limited allowed dma coherent/writecombine allocations.

This experimental patch series replaces custom consistent dma regions
usage in dma-mapping framework in favour of generic vmalloc areas
created on demand for each coherent and writecombine allocations.

This patch is based on vanilla v3.4-rc2 release.

Best regards
Marek Szyprowski
Samsung Poland R&D Center


Patch summary:

Marek Szyprowski (4):
  mm: vmalloc: use const void * for caller argument
  mm: vmalloc: export find_vm_area() function
  mm: vmalloc: add VM_DMA flag to indicate areas used by dma-mapping
    framework
  ARM: remove consistent dma region and use common vmalloc range for
    dma allocations

 arch/arm/include/asm/dma-mapping.h |    2 +-
 arch/arm/mm/dma-mapping.c          |  220 +++++++-----------------------------
 include/linux/vmalloc.h            |   10 +-
 mm/vmalloc.c                       |   31 ++++--
 4 files changed, 67 insertions(+), 196 deletions(-)

-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
