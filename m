Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id C3ADA6B000A
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 00:45:22 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id 78so9766875pfw.2
        for <linux-mm@kvack.org>; Sun, 20 Dec 2015 21:45:22 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id r6si1339114pap.176.2015.12.20.21.45.11
        for <linux-mm@kvack.org>;
        Sun, 20 Dec 2015 21:45:11 -0800 (PST)
Subject: [-mm PATCH v4 07/18] avr32: convert to asm-generic/memory_model.h
From: Dan Williams <dan.j.williams@intel.com>
Date: Sun, 20 Dec 2015 21:44:44 -0800
Message-ID: <20151221054444.34542.92752.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151221054406.34542.64393.stgit@dwillia2-desk3.jf.intel.com>
References: <20151221054406.34542.64393.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-nvdimm@lists.01.org

Switch avr32/include/asm/page.h to use the common defintions for
pfn_to_page(), page_to_pfn(), and ARCH_PFN_OFFSET.

Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/avr32/include/asm/page.h |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/arch/avr32/include/asm/page.h b/arch/avr32/include/asm/page.h
index f805d1cb11bc..c5d2a3e2c62f 100644
--- a/arch/avr32/include/asm/page.h
+++ b/arch/avr32/include/asm/page.h
@@ -83,11 +83,9 @@ static inline int get_order(unsigned long size)
 
 #ifndef CONFIG_NEED_MULTIPLE_NODES
 
-#define PHYS_PFN_OFFSET		(CONFIG_PHYS_OFFSET >> PAGE_SHIFT)
+#define ARCH_PFN_OFFSET		(CONFIG_PHYS_OFFSET >> PAGE_SHIFT)
 
-#define pfn_to_page(pfn)	(mem_map + ((pfn) - PHYS_PFN_OFFSET))
-#define page_to_pfn(page)	((unsigned long)((page) - mem_map) + PHYS_PFN_OFFSET)
-#define pfn_valid(pfn)		((pfn) >= PHYS_PFN_OFFSET && (pfn) < (PHYS_PFN_OFFSET + max_mapnr))
+#define pfn_valid(pfn)		((pfn) >= ARCH_PFN_OFFSET && (pfn) < (ARCH_PFN_OFFSET + max_mapnr))
 #endif /* CONFIG_NEED_MULTIPLE_NODES */
 
 #define virt_to_page(kaddr)	pfn_to_page(__pa(kaddr) >> PAGE_SHIFT)
@@ -101,4 +99,6 @@ static inline int get_order(unsigned long size)
  */
 #define HIGHMEM_START		0x20000000UL
 
+#include <asm-generic/memory_model.h>
+
 #endif /* __ASM_AVR32_PAGE_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
