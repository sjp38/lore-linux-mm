Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 6C9746B006C
	for <linux-mm@kvack.org>; Mon, 26 Nov 2012 08:42:19 -0500 (EST)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0ME3000K8KQHMM00@mailout1.samsung.com> for
 linux-mm@kvack.org; Mon, 26 Nov 2012 22:42:17 +0900 (KST)
Received: from localhost.localdomain ([106.116.147.30])
 by mmp2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0ME300LU3KQ7P550@mmp2.samsung.com> for linux-mm@kvack.org;
 Mon, 26 Nov 2012 22:42:17 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH] dma-mapping: fix dma_common_get_sgtable() conditional
 compilation
Date: Mon, 26 Nov 2012 14:41:48 +0100
Message-id: <1353937308-887-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Mauro Carvalho Chehab <mchehab@infradead.org>

dma_common_get_sgtable() function doesn't depend on
ARCH_HAS_DMA_DECLARE_COHERENT_MEMORY, so it must not be compiled
conditionally.

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
---
 drivers/base/dma-mapping.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/base/dma-mapping.c b/drivers/base/dma-mapping.c
index 3fbedc7..0ce39a3 100644
--- a/drivers/base/dma-mapping.c
+++ b/drivers/base/dma-mapping.c
@@ -218,6 +218,8 @@ void dmam_release_declared_memory(struct device *dev)
 }
 EXPORT_SYMBOL(dmam_release_declared_memory);
 
+#endif
+
 /*
  * Create scatter-list for the already allocated DMA buffer.
  */
@@ -236,8 +238,6 @@ int dma_common_get_sgtable(struct device *dev, struct sg_table *sgt,
 }
 EXPORT_SYMBOL(dma_common_get_sgtable);
 
-#endif
-
 /*
  * Create userspace mapping for the DMA-coherent memory.
  */
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
