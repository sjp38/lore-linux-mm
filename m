Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 8F1F382F64
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 20:34:13 -0500 (EST)
Received: by pacej9 with SMTP id ej9so3067453pac.2
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 17:34:13 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id fk1si1325966pad.35.2015.12.07.17.34.12
        for <linux-mm@kvack.org>;
        Mon, 07 Dec 2015 17:34:12 -0800 (PST)
Subject: [PATCH -mm 13/25] avr32: convert to asm-generic/memory_model.h
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 07 Dec 2015 17:33:45 -0800
Message-ID: <20151208013345.25030.74379.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20151208013236.25030.68781.stgit@dwillia2-desk3.jf.intel.com>
References: <20151208013236.25030.68781.stgit@dwillia2-desk3.jf.intel.com>
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
