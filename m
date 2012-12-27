Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 0EAE26B002B
	for <linux-mm@kvack.org>; Thu, 27 Dec 2012 01:51:56 -0500 (EST)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MFO00645GEIKSR0@mailout3.samsung.com> for
 linux-mm@kvack.org; Thu, 27 Dec 2012 15:51:55 +0900 (KST)
Received: from chrome-ubuntu.sisodomain.com ([107.108.73.106])
 by mmp2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTPA id <0MFO009SEGEEF090@mmp2.samsung.com> for
 linux-mm@kvack.org; Thu, 27 Dec 2012 15:51:55 +0900 (KST)
From: Prathyush K <prathyush.k@samsung.com>
Subject: [PATCH] arm: dma mapping: export arm iommu functions
Date: Thu, 27 Dec 2012 02:14:18 -0500
Message-id: <1356592458-11077-1-git-send-email-prathyush.k@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org
Cc: m.szyprowski@samsung.com, prathyush@chromium.org

This patch adds EXPORT_SYMBOL calls to the three arm iommu
functions - arm_iommu_create_mapping, arm_iommu_free_mapping
and arm_iommu_attach_device. These functions can now be called
from dynamic modules.

Signed-off-by: Prathyush K <prathyush.k@samsung.com>
---
 arch/arm/mm/dma-mapping.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 6b2fb87..c0f0f43 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -1797,6 +1797,7 @@ err2:
 err:
 	return ERR_PTR(err);
 }
+EXPORT_SYMBOL(arm_iommu_create_mapping);
 
 static void release_iommu_mapping(struct kref *kref)
 {
@@ -1813,6 +1814,7 @@ void arm_iommu_release_mapping(struct dma_iommu_mapping *mapping)
 	if (mapping)
 		kref_put(&mapping->kref, release_iommu_mapping);
 }
+EXPORT_SYMBOL(arm_iommu_release_mapping);
 
 /**
  * arm_iommu_attach_device
@@ -1841,5 +1843,6 @@ int arm_iommu_attach_device(struct device *dev,
 	pr_debug("Attached IOMMU controller to %s device.\n", dev_name(dev));
 	return 0;
 }
+EXPORT_SYMBOL(arm_iommu_attach_device);
 
 #endif
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
