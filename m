Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 216446B00A3
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 10:06:30 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MBX0029FTRG5T90@mailout2.samsung.com> for
 linux-mm@kvack.org; Mon, 15 Oct 2012 23:04:28 +0900 (KST)
Received: from localhost.localdomain ([106.116.147.30])
 by mmp1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTPA id <0MBX00JMCTQOCL70@mmp1.samsung.com> for linux-mm@kvack.org;
 Mon, 15 Oct 2012 23:04:27 +0900 (KST)
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [RFC 1/2] common: DMA-mapping: add DMA_ATTR_FORCE_CONTIGUOUS attribute
Date: Mon, 15 Oct 2012 16:03:51 +0200
Message-id: <1350309832-18461-2-git-send-email-m.szyprowski@samsung.com>
In-reply-to: <1350309832-18461-1-git-send-email-m.szyprowski@samsung.com>
References: <1350309832-18461-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Arnd Bergmann <arnd@arndb.de>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Inki Dae <inki.dae@samsung.com>, Rob Clark <rob@ti.com>

This patch adds DMA_ATTR_FORCE_CONTIGUOUS attribute to the DMA-mapping
subsystem.

By default DMA-mapping subsystem is allowed to assemble the buffer
allocated by dma_alloc_attrs() function from individual pages if it can
be mapped as contiguous chunk into device dma address space. By
specifing this attribute the allocated buffer is forced to be contiguous
also in physical memory.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
---
 Documentation/DMA-attributes.txt |    9 +++++++++
 include/linux/dma-attrs.h        |    1 +
 2 files changed, 10 insertions(+)

diff --git a/Documentation/DMA-attributes.txt b/Documentation/DMA-attributes.txt
index f503090..e59480d 100644
--- a/Documentation/DMA-attributes.txt
+++ b/Documentation/DMA-attributes.txt
@@ -91,3 +91,12 @@ transferred to 'device' domain. This attribute can be also used for
 dma_unmap_{single,page,sg} functions family to force buffer to stay in
 device domain after releasing a mapping for it. Use this attribute with
 care!
+
+DMA_ATTR_FORCE_CONTIGUOUS
+-------------------------
+
+By default DMA-mapping subsystem is allowed to assemble the buffer
+allocated by dma_alloc_attrs() function from individual pages if it can
+be mapped as contiguous chunk into device dma address space. By
+specifing this attribute the allocated buffer is forced to be contiguous
+also in physical memory.
diff --git a/include/linux/dma-attrs.h b/include/linux/dma-attrs.h
index f83f793..c8e1831 100644
--- a/include/linux/dma-attrs.h
+++ b/include/linux/dma-attrs.h
@@ -17,6 +17,7 @@ enum dma_attr {
 	DMA_ATTR_NON_CONSISTENT,
 	DMA_ATTR_NO_KERNEL_MAPPING,
 	DMA_ATTR_SKIP_CPU_SYNC,
+	DMA_ATTR_FORCE_CONTIGUOUS,
 	DMA_ATTR_MAX,
 };
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
