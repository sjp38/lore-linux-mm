Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 50DB66B0253
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 16:21:15 -0500 (EST)
Received: by mail-pa0-f72.google.com with SMTP id ro13so80780580pac.7
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 13:21:15 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id c16si1275048pfc.102.2016.11.09.13.21.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Nov 2016 13:21:14 -0800 (PST)
Subject: [swiotlb PATCH v3 1/3] swiotlb: remove unused swiotlb_map_sg and
 swiotlb_unmap_sg functions
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Wed, 09 Nov 2016 10:20:10 -0500
Message-ID: <20161109152002.25151.39370.stgit@ahduyck-blue-test.jf.intel.com>
In-Reply-To: <20161109151639.25151.24290.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161109151639.25151.24290.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, konrad.wilk@oracle.com
Cc: netdev@vger.kernel.org, Christoph Hellwig <hch@lst.de>, linux-kernel@vger.kernel.org

From: Christoph Hellwig <hch@lst.de>

Signed-off-by: Christoph Hellwig <hch@lst.de>
Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
---
 include/linux/swiotlb.h |    8 --------
 lib/swiotlb.c           |   16 ----------------
 2 files changed, 24 deletions(-)

diff --git a/include/linux/swiotlb.h b/include/linux/swiotlb.h
index 5f81f8a..f0d2589 100644
--- a/include/linux/swiotlb.h
+++ b/include/linux/swiotlb.h
@@ -73,14 +73,6 @@ extern void swiotlb_unmap_page(struct device *hwdev, dma_addr_t dev_addr,
 			       unsigned long attrs);
 
 extern int
-swiotlb_map_sg(struct device *hwdev, struct scatterlist *sg, int nents,
-	       enum dma_data_direction dir);
-
-extern void
-swiotlb_unmap_sg(struct device *hwdev, struct scatterlist *sg, int nents,
-		 enum dma_data_direction dir);
-
-extern int
 swiotlb_map_sg_attrs(struct device *hwdev, struct scatterlist *sgl, int nelems,
 		     enum dma_data_direction dir,
 		     unsigned long attrs);
diff --git a/lib/swiotlb.c b/lib/swiotlb.c
index 22e13a0..5005316 100644
--- a/lib/swiotlb.c
+++ b/lib/swiotlb.c
@@ -910,14 +910,6 @@ swiotlb_map_sg_attrs(struct device *hwdev, struct scatterlist *sgl, int nelems,
 }
 EXPORT_SYMBOL(swiotlb_map_sg_attrs);
 
-int
-swiotlb_map_sg(struct device *hwdev, struct scatterlist *sgl, int nelems,
-	       enum dma_data_direction dir)
-{
-	return swiotlb_map_sg_attrs(hwdev, sgl, nelems, dir, 0);
-}
-EXPORT_SYMBOL(swiotlb_map_sg);
-
 /*
  * Unmap a set of streaming mode DMA translations.  Again, cpu read rules
  * concerning calls here are the same as for swiotlb_unmap_page() above.
@@ -938,14 +930,6 @@ swiotlb_unmap_sg_attrs(struct device *hwdev, struct scatterlist *sgl,
 }
 EXPORT_SYMBOL(swiotlb_unmap_sg_attrs);
 
-void
-swiotlb_unmap_sg(struct device *hwdev, struct scatterlist *sgl, int nelems,
-		 enum dma_data_direction dir)
-{
-	return swiotlb_unmap_sg_attrs(hwdev, sgl, nelems, dir, 0);
-}
-EXPORT_SYMBOL(swiotlb_unmap_sg);
-
 /*
  * Make physical memory consistent for a set of streaming mode DMA translations
  * after a transfer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
