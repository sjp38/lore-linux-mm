Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 43A786B006E
	for <linux-mm@kvack.org>; Fri, 23 Dec 2011 07:28:07 -0500 (EST)
Received: from euspt2 (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0LWN007L3PAMRU@mailout2.w1.samsung.com> for linux-mm@kvack.org;
 Fri, 23 Dec 2011 12:28:00 +0000 (GMT)
Received: from linux.samsung.com ([106.116.38.10])
 by spt2.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0LWN009B0PAN85@spt2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 23 Dec 2011 12:27:59 +0000 (GMT)
Date: Fri, 23 Dec 2011 13:27:30 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
Subject: [PATCH 11/14] common: dma-mapping: remove old alloc_coherent and
 free_coherent methods
In-reply-to: <1324643253-3024-1-git-send-email-m.szyprowski@samsung.com>
Message-id: <1324643253-3024-12-git-send-email-m.szyprowski@samsung.com>
MIME-version: 1.0
Content-type: TEXT/PLAIN
Content-transfer-encoding: 7BIT
References: <1324643253-3024-1-git-send-email-m.szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Stephen Rothwell <sfr@canb.auug.org.au>, microblaze-uclinux@itee.uq.edu.au, linux-arch@vger.kernel.org, x86@kernel.org, linux-sh@vger.kernel.org, linux-alpha@vger.kernel.org, sparclinux@vger.kernel.org, linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mips@linux-mips.org, discuss@x86-64.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Jonathan Corbet <corbet@lwn.net>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Andrzej Pietrasiewicz <andrzej.p@samsung.com>

Remove old, unused alloc_coherent and free_coherent methods from
dma_map_ops structure.

Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 include/linux/dma-mapping.h |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/include/linux/dma-mapping.h b/include/linux/dma-mapping.h
index 8cc7f95..2fc413a 100644
--- a/include/linux/dma-mapping.h
+++ b/include/linux/dma-mapping.h
@@ -9,10 +9,6 @@
 #include <linux/scatterlist.h>
 
 struct dma_map_ops {
-	void* (*alloc_coherent)(struct device *dev, size_t size,
-				dma_addr_t *dma_handle, gfp_t gfp);
-	void (*free_coherent)(struct device *dev, size_t size,
-			      void *vaddr, dma_addr_t dma_handle);
 	void* (*alloc)(struct device *dev, size_t size,
 				dma_addr_t *dma_handle, gfp_t gfp,
 				struct dma_attrs *attrs);
-- 
1.7.1.569.g6f426

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
