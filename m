Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 12E746B0038
	for <linux-mm@kvack.org>; Thu, 21 Aug 2014 04:45:36 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id rd3so14163199pab.40
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 01:45:35 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id ov10si35450725pbb.86.2014.08.21.01.45.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 21 Aug 2014 01:45:34 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NAN009DHF4J7T70@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 21 Aug 2014 09:48:19 +0100 (BST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 2/2] ARM: mm: don't limit default CMA region only to low memory
Date: Thu, 21 Aug 2014 10:45:14 +0200
Message-id: <1408610714-16204-3-git-send-email-m.szyprowski@samsung.com>
In-reply-to: <1408610714-16204-1-git-send-email-m.szyprowski@samsung.com>
References: <1408610714-16204-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Michal Nazarewicz <mina86@mina86.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>

DMA-mapping supports CMA regions places either in low or high memory, so
there is no longer needed to limit default CMA regions only to low memory.
The real limit is still defined by architecture specific DMA limit.

Reported-by: Russell King - ARM Linux <linux@arm.linux.org.uk>
Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
---
 arch/arm/mm/init.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index 659c75d808dc..c1b513555786 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -322,7 +322,7 @@ void __init arm_memblock_init(const struct machine_desc *mdesc)
 	 * reserve memory for DMA contigouos allocations,
 	 * must come from DMA area inside low memory
 	 */
-	dma_contiguous_reserve(min(arm_dma_limit, arm_lowmem_limit));
+	dma_contiguous_reserve(arm_dma_limit);
 
 	arm_memblock_steal_permitted = false;
 	memblock_dump_all();
-- 
1.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
