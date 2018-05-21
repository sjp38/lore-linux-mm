Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5EEC16B000C
	for <linux-mm@kvack.org>; Mon, 21 May 2018 11:21:08 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id f35-v6so10198422plb.10
        for <linux-mm@kvack.org>; Mon, 21 May 2018 08:21:08 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v15-v6sor5847824pff.49.2018.05.21.08.21.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 21 May 2018 08:21:07 -0700 (PDT)
From: Huaisheng Ye <yehs2007@gmail.com>
Subject: [RFC PATCH v2 05/12] include/linux/dma-mapping: update usage of address zone modifiers
Date: Mon, 21 May 2018 23:20:26 +0800
Message-Id: <1526916033-4877-6-git-send-email-yehs2007@gmail.com>
In-Reply-To: <1526916033-4877-1-git-send-email-yehs2007@gmail.com>
References: <1526916033-4877-1-git-send-email-yehs2007@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: mhocko@suse.com, willy@infradead.org, vbabka@suse.cz, mgorman@techsingularity.net, kstewart@linuxfoundation.org, alexander.levin@verizon.com, gregkh@linuxfoundation.org, colyli@suse.de, chengnt@lenovo.com, hehy1@lenovo.com, linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org, xen-devel@lists.xenproject.org, linux-btrfs@vger.kernel.org, Huaisheng Ye <yehs1@lenovo.com>, Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>

From: Huaisheng Ye <yehs1@lenovo.com>

Use __GFP_ZONE_MASK to replace (__GFP_DMA | __GFP_HIGHMEM | __GFP_DMA32).

___GFP_DMA, ___GFP_HIGHMEM and ___GFP_DMA32 have been deleted from GFP
bitmasks, the bottom three bits of GFP mask is reserved for storing
encoded zone number.
__GFP_DMA, __GFP_HIGHMEM and __GFP_DMA32 should not be operated with
each others by OR.

Signed-off-by: Huaisheng Ye <yehs1@lenovo.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Robin Murphy <robin.murphy@arm.com>
---
 include/linux/dma-mapping.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index eb9eab4..3da0293 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -523,7 +523,7 @@ static inline void *dma_alloc_attrs(struct device *dev, size_t size,
 	 * decide on the way of zeroing the memory given that the memory
 	 * returned should always be zeroed.
 	 */
-	flag &= ~(__GFP_DMA | __GFP_DMA32 | __GFP_HIGHMEM | __GFP_ZERO);
+	flag &= ~(__GFP_ZONE_MASK | __GFP_ZERO);
 
 	if (!arch_dma_alloc_attrs(&dev, &flag))
 		return NULL;
-- 
1.8.3.1
