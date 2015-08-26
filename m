Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 27CE69003C7
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 21:33:43 -0400 (EDT)
Received: by pacdd16 with SMTP id dd16so142023170pac.2
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 18:33:42 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id pn9si31286264pdb.45.2015.08.25.18.33.42
        for <linux-mm@kvack.org>;
        Tue, 25 Aug 2015 18:33:42 -0700 (PDT)
Subject: [PATCH v2 2/9] mm: move __phys_to_pfn and __pfn_to_phys to
 asm/generic/memory_model.h
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 25 Aug 2015 21:27:35 -0400
Message-ID: <20150826012735.8851.49787.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <20150826010220.8851.18077.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <20150826010220.8851.18077.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: boaz@plexistor.com, david@fromorbit.com, linux-kernel@vger.kernel.org, hch@lst.de, linux-mm@kvack.org, hpa@zytor.com, ross.zwisler@linux.intel.com, mingo@kernel.org

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
