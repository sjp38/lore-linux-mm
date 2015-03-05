Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id 5D6256B0038
	for <linux-mm@kvack.org>; Thu,  5 Mar 2015 11:40:51 -0500 (EST)
Received: by oiav63 with SMTP id v63so12671331oia.8
        for <linux-mm@kvack.org>; Thu, 05 Mar 2015 08:40:51 -0800 (PST)
Received: from g2t2353.austin.hp.com (g2t2353.austin.hp.com. [15.217.128.52])
        by mx.google.com with ESMTPS id q8si4298280oej.21.2015.03.05.08.40.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Mar 2015 08:40:50 -0800 (PST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH] Fix build errors in asm-generic/pgtable.h
Date: Thu,  5 Mar 2015 09:40:07 -0700
Message-Id: <1425573607-4801-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-next@vger.kernel.org, linux-kernel@vger.kernel.org, kbuild-all@01.org, fengguang.wu@intel.com, hannes@cmpxchg.org, Toshi Kani <toshi.kani@hp.com>

Fix build errors in pud_set_huge() and pmd_set_huge() in
asm-generic/pgtable.h on some architectures in linux-next
and -mm trees.

C-stype code needs be used under #ifndef __ASSEMBLY__.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 include/asm-generic/pgtable.h |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index eaae472..c79eebf 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -697,12 +697,6 @@ static inline int pmd_protnone(pmd_t pmd)
 
 #endif /* CONFIG_MMU */
 
-#endif /* !__ASSEMBLY__ */
-
-#ifndef io_remap_pfn_range
-#define io_remap_pfn_range remap_pfn_range
-#endif
-
 #ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
 int pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot);
 int pmd_set_huge(pmd_t *pmd, phys_addr_t addr, pgprot_t prot);
@@ -721,4 +715,10 @@ static inline int pud_clear_huge(pud_t *pud) { return 0; }
 static inline int pmd_clear_huge(pmd_t *pmd) { return 0; }
 #endif	/* CONFIG_HAVE_ARCH_HUGE_VMAP */
 
+#endif /* !__ASSEMBLY__ */
+
+#ifndef io_remap_pfn_range
+#define io_remap_pfn_range remap_pfn_range
+#endif
+
 #endif /* _ASM_GENERIC_PGTABLE_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
