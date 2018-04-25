Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id F23F36B0024
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 01:16:50 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id s7so1612623pgp.15
        for <linux-mm@kvack.org>; Tue, 24 Apr 2018 22:16:50 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l5-v6si15014948pls.144.2018.04.24.22.16.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 24 Apr 2018 22:16:49 -0700 (PDT)
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH 13/13] swiotlb: remove the CONFIG_DMA_DIRECT_OPS ifdefs
Date: Wed, 25 Apr 2018 07:15:39 +0200
Message-Id: <20180425051539.1989-14-hch@lst.de>
In-Reply-To: <20180425051539.1989-1-hch@lst.de>
References: <20180425051539.1989-1-hch@lst.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, iommu@lists.linux-foundation.org
Cc: sstabellini@kernel.org, x86@kernel.org, linux-pci@vger.kernel.org, linux-mm@kvack.org, linux-mips@linux-mips.org, sparclinux@vger.kernel.org, linux-arm-kernel@lists.infradead.org

swiotlb now selects the DMA_DIRECT_OPS config symbol, so this will
always be true.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 lib/swiotlb.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/lib/swiotlb.c b/lib/swiotlb.c
index fece57566d45..6954f7ad200a 100644
--- a/lib/swiotlb.c
+++ b/lib/swiotlb.c
@@ -692,7 +692,6 @@ void swiotlb_tbl_sync_single(struct device *hwdev, phys_addr_t tlb_addr,
 	}
 }
 
-#ifdef CONFIG_DMA_DIRECT_OPS
 static inline bool dma_coherent_ok(struct device *dev, dma_addr_t addr,
 		size_t size)
 {
@@ -764,7 +763,6 @@ static bool swiotlb_free_buffer(struct device *dev, size_t size,
 				 DMA_ATTR_SKIP_CPU_SYNC);
 	return true;
 }
-#endif
 
 static void
 swiotlb_full(struct device *dev, size_t size, enum dma_data_direction dir,
@@ -1045,7 +1043,6 @@ swiotlb_dma_supported(struct device *hwdev, u64 mask)
 	return __phys_to_dma(hwdev, io_tlb_end - 1) <= mask;
 }
 
-#ifdef CONFIG_DMA_DIRECT_OPS
 void *swiotlb_alloc(struct device *dev, size_t size, dma_addr_t *dma_handle,
 		gfp_t gfp, unsigned long attrs)
 {
@@ -1089,4 +1086,3 @@ const struct dma_map_ops swiotlb_dma_ops = {
 	.unmap_page		= swiotlb_unmap_page,
 	.dma_supported		= dma_direct_supported,
 };
-#endif /* CONFIG_DMA_DIRECT_OPS */
-- 
2.17.0
