Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Huaisheng Ye <yehs2007@163.com>
Subject: [RFC PATCH v3 2/9] include/linux/dma-mapping: update usage of zone modifiers
Date: Wed, 23 May 2018 22:57:47 +0800
Message-Id: <1527087474-93986-3-git-send-email-yehs2007@163.com>
In-Reply-To: <1527087474-93986-1-git-send-email-yehs2007@163.com>
References: <1527087474-93986-1-git-send-email-yehs2007@163.com>
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: mhocko@suse.com, willy@infradead.org, hch@lst.de, vbabka@suse.cz, mgorman@techsingularity.net, kstewart@linuxfoundation.org, gregkh@linuxfoundation.org, colyli@suse.de, chengnt@lenovo.com, hehy1@lenovo.com, linux-kernel@vger.kernel.org, iommu@lists.linux-foundation.org, xen-devel@lists.xenproject.org, linux-btrfs@vger.kernel.org, Huaisheng Ye <yehs1@lenovo.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Robin Murphy <robin.murphy@arm.com>, Christoph Hellwig <hch@infradead.org>
List-ID: <linux-mm.kvack.org>

From: Huaisheng Ye <yehs1@lenovo.com>

Use __GFP_ZONE_MASK to replace (__GFP_DMA | __GFP_HIGHMEM | __GFP_DMA32).

___GFP_DMA, ___GFP_HIGHMEM and ___GFP_DMA32 have been deleted from GFP
bitmasks, the bottom three bits of GFP mask is reserved for storing
encoded zone number.
__GFP_DMA, __GFP_HIGHMEM and __GFP_DMA32 should not be operated with
each others by OR.

Use GFP_NORMAL() to clear bottom 3 bits of GFP bitmaks.

Signed-off-by: Huaisheng Ye <yehs1@lenovo.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: Robin Murphy <robin.murphy@arm.com>
Cc: Christoph Hellwig <hch@infradead.org>
---
 include/linux/dma-mapping.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index f8ab1c0..8fe524d 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -519,7 +519,7 @@ static inline void *dma_alloc_attrs(struct device *dev, size_t size,
 		return cpu_addr;
 
 	/* let the implementation decide on the zone to allocate from: */
-	flag &= ~(__GFP_DMA | __GFP_DMA32 | __GFP_HIGHMEM);
+	flag = GFP_NORMAL(flag);
 
 	if (!arch_dma_alloc_attrs(&dev, &flag))
 		return NULL;
-- 
1.8.3.1
