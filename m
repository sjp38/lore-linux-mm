Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 28CED6B0255
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 00:47:02 -0400 (EDT)
Received: by pacbt3 with SMTP id bt3so10899565pac.3
        for <linux-mm@kvack.org>; Tue, 22 Sep 2015 21:47:01 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id je14si7690496pbd.124.2015.09.22.21.47.01
        for <linux-mm@kvack.org>;
        Tue, 22 Sep 2015 21:47:01 -0700 (PDT)
Subject: [PATCH 01/15] avr32: convert to asm-generic/memory_model.h
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 23 Sep 2015 00:41:18 -0400
Message-ID: <20150923044118.36490.75919.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
References: <20150923043737.36490.70547.stgit@dwillia2-desk3.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org

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
