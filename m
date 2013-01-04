Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id DC3A66B005A
	for <linux-mm@kvack.org>; Fri,  4 Jan 2013 06:00:35 -0500 (EST)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MG300ATRL89TOI0@mailout4.samsung.com> for
 linux-mm@kvack.org; Fri, 04 Jan 2013 20:00:34 +0900 (KST)
Received: from chrome-ubuntu.sisodomain.com ([107.108.73.106])
 by mmp2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTPA id <0MG300AN1L8SN090@mmp2.samsung.com> for
 linux-mm@kvack.org; Fri, 04 Jan 2013 20:00:33 +0900 (KST)
From: Prathyush K <prathyush.k@samsung.com>
Subject: [PATCH v2] arm: dma mapping: export arm iommu functions
Date: Fri, 04 Jan 2013 06:22:42 -0500
Message-id: <1357298562-28110-1-git-send-email-prathyush.k@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org
Cc: m.szyprowski@samsung.com, prathyush@chromium.org

This patch adds EXPORT_SYMBOL_GPL calls to the three arm iommu
functions - arm_iommu_create_mapping, arm_iommu_free_mapping
and arm_iommu_attach_device. These three functions are arm specific
wrapper functions for creating/freeing/using an iommu mapping and
they are called by various drivers. If any of these drivers need
to be built as dynamic modules, these functions need to be exported.

Changelog v2: using EXPORT_SYMBOL_GPL as suggested by Marek.

Signed-off-by: Prathyush K <prathyush.k@samsung.com>
---
 arch/arm/mm/dma-mapping.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index 6b2fb87..226ebcf 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -1797,6 +1797,7 @@ err2:
 err:
 	return ERR_PTR(err);
 }
+EXPORT_SYMBOL_GPL(arm_iommu_create_mapping);
 
 static void release_iommu_mapping(struct kref *kref)
 {
@@ -1813,6 +1814,7 @@ void arm_iommu_release_mapping(struct dma_iommu_mapping *mapping)
 	if (mapping)
 		kref_put(&mapping->kref, release_iommu_mapping);
 }
+EXPORT_SYMBOL_GPL(arm_iommu_release_mapping);
 
 /**
  * arm_iommu_attach_device
@@ -1841,5 +1843,6 @@ int arm_iommu_attach_device(struct device *dev,
 	pr_debug("Attached IOMMU controller to %s device.\n", dev_name(dev));
 	return 0;
 }
+EXPORT_SYMBOL_GPL(arm_iommu_attach_device);
 
 #endif
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
