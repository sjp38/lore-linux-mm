Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8057F280250
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 14:05:09 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id xx10so2554001pac.2
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 11:05:09 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id v2si16608660pfi.172.2016.10.24.11.05.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 11:05:08 -0700 (PDT)
Subject: [net-next PATCH RFC 01/26] swiotlb: Drop unused function
 swiotlb_map_sg
From: Alexander Duyck <alexander.h.duyck@intel.com>
Date: Mon, 24 Oct 2016 08:04:31 -0400
Message-ID: <20161024120431.16276.89246.stgit@ahduyck-blue-test.jf.intel.com>
In-Reply-To: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
References: <20161024115737.16276.71059.stgit@ahduyck-blue-test.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: brouer@redhat.com, davem@davemloft.net, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

There are no users for swiotlb_map_sg so we might as well just drop it.

Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---
 include/linux/swiotlb.h |    4 ----
 lib/swiotlb.c           |    8 --------
 2 files changed, 12 deletions(-)

diff --git a/include/linux/swiotlb.h b/include/linux/swiotlb.h
index 5f81f8a..e237b6f 100644
--- a/include/linux/swiotlb.h
+++ b/include/linux/swiotlb.h
@@ -72,10 +72,6 @@ extern void swiotlb_unmap_page(struct device *hwdev, dma_addr_t dev_addr,
 			       size_t size, enum dma_data_direction dir,
 			       unsigned long attrs);
 
-extern int
-swiotlb_map_sg(struct device *hwdev, struct scatterlist *sg, int nents,
-	       enum dma_data_direction dir);
-
 extern void
 swiotlb_unmap_sg(struct device *hwdev, struct scatterlist *sg, int nents,
 		 enum dma_data_direction dir);
diff --git a/lib/swiotlb.c b/lib/swiotlb.c
index 22e13a0..47aad37 100644
--- a/lib/swiotlb.c
+++ b/lib/swiotlb.c
@@ -910,14 +910,6 @@ void swiotlb_unmap_page(struct device *hwdev, dma_addr_t dev_addr,
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
