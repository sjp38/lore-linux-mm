Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id C1A1E6B0253
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 23:06:47 -0400 (EDT)
Received: by pacgr6 with SMTP id gr6so27509747pac.2
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 20:06:47 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id m7si1313400pdp.145.2015.08.12.20.06.46
        for <linux-mm@kvack.org>;
        Wed, 12 Aug 2015 20:06:47 -0700 (PDT)
Subject: [PATCH v5 1/5] mm: move __phys_to_pfn and __pfn_to_phys to
 asm/generic/memory_model.h
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 12 Aug 2015 23:01:04 -0400
Message-ID: <20150813030104.36703.50646.stgit@otcpl-skl-sds-2.jf.intel.com>
In-Reply-To: <20150813025112.36703.21333.stgit@otcpl-skl-sds-2.jf.intel.com>
References: <20150813025112.36703.21333.stgit@otcpl-skl-sds-2.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: axboe@kernel.dk, riel@redhat.com, linux-nvdimm@lists.01.org, linux-mm@kvack.org, mgorman@suse.de, torvalds@linux-foundation.org, hch@lst.de

From: Christoph Hellwig <hch@lst.de>

Three architectures already define these, and we'll need them genericly
soon.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/arm/include/asm/memory.h       |    6 ------
 arch/arm64/include/asm/memory.h     |    6 ------
 arch/unicore32/include/asm/memory.h |    6 ------
 include/asm-generic/memory_model.h  |    6 ++++++
 4 files changed, 6 insertions(+), 18 deletions(-)

diff --git a/arch/arm/include/asm/memory.h b/arch/arm/include/asm/memory.h
index b7f6fb462ea0..98d58bb04ac5 100644
--- a/arch/arm/include/asm/memory.h
+++ b/arch/arm/include/asm/memory.h
@@ -119,12 +119,6 @@
 #endif
 
 /*
- * Convert a physical address to a Page Frame Number and back
- */
-#define	__phys_to_pfn(paddr)	((unsigned long)((paddr) >> PAGE_SHIFT))
-#define	__pfn_to_phys(pfn)	((phys_addr_t)(pfn) << PAGE_SHIFT)
-
-/*
  * Convert a page to/from a physical address
  */
 #define page_to_phys(page)	(__pfn_to_phys(page_to_pfn(page)))
diff --git a/arch/arm64/include/asm/memory.h b/arch/arm64/include/asm/memory.h
index f800d45ea226..d808bb688751 100644
--- a/arch/arm64/include/asm/memory.h
+++ b/arch/arm64/include/asm/memory.h
@@ -81,12 +81,6 @@
 #define __phys_to_virt(x)	((unsigned long)((x) - PHYS_OFFSET + PAGE_OFFSET))
 
 /*
- * Convert a physical address to a Page Frame Number and back
- */
-#define	__phys_to_pfn(paddr)	((unsigned long)((paddr) >> PAGE_SHIFT))
-#define	__pfn_to_phys(pfn)	((phys_addr_t)(pfn) << PAGE_SHIFT)
-
-/*
  * Convert a page to/from a physical address
  */
 #define page_to_phys(page)	(__pfn_to_phys(page_to_pfn(page)))
diff --git a/arch/unicore32/include/asm/memory.h b/arch/unicore32/include/asm/memory.h
index debafc40200a..3bb0a29fd2d7 100644
--- a/arch/unicore32/include/asm/memory.h
+++ b/arch/unicore32/include/asm/memory.h
@@ -61,12 +61,6 @@
 #endif
 
 /*
- * Convert a physical address to a Page Frame Number and back
- */
-#define	__phys_to_pfn(paddr)	((paddr) >> PAGE_SHIFT)
-#define	__pfn_to_phys(pfn)	((pfn) << PAGE_SHIFT)
-
-/*
  * Convert a page to/from a physical address
  */
 #define page_to_phys(page)	(__pfn_to_phys(page_to_pfn(page)))
diff --git a/include/asm-generic/memory_model.h b/include/asm-generic/memory_model.h
index 14909b0b9cae..f20f407ce45d 100644
--- a/include/asm-generic/memory_model.h
+++ b/include/asm-generic/memory_model.h
@@ -69,6 +69,12 @@
 })
 #endif /* CONFIG_FLATMEM/DISCONTIGMEM/SPARSEMEM */
 
+/*
+ * Convert a physical address to a Page Frame Number and back
+ */
+#define	__phys_to_pfn(paddr)	((unsigned long)((paddr) >> PAGE_SHIFT))
+#define	__pfn_to_phys(pfn)	((pfn) << PAGE_SHIFT)
+
 #define page_to_pfn __page_to_pfn
 #define pfn_to_page __pfn_to_page
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
