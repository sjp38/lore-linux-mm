Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 86B7A6B0034
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 22:08:05 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 3/4] mm: move pgtable related functions to right place
Date: Fri,  2 Aug 2013 11:07:58 +0900
Message-Id: <1375409279-16919-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1375409279-16919-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1375409279-16919-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

pgtable related functions are mostly in pgtable-generic.c.
So move remaining functions from memory.c to pgtable-generic.c.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/memory.c b/mm/memory.c
index 1ce2e2a..26bce51 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -374,30 +374,6 @@ void tlb_remove_table(struct mmu_gather *tlb, void *table)
 #endif /* CONFIG_HAVE_RCU_TABLE_FREE */
 
 /*
- * If a p?d_bad entry is found while walking page tables, report
- * the error, before resetting entry to p?d_none.  Usually (but
- * very seldom) called out from the p?d_none_or_clear_bad macros.
- */
-
-void pgd_clear_bad(pgd_t *pgd)
-{
-	pgd_ERROR(*pgd);
-	pgd_clear(pgd);
-}
-
-void pud_clear_bad(pud_t *pud)
-{
-	pud_ERROR(*pud);
-	pud_clear(pud);
-}
-
-void pmd_clear_bad(pmd_t *pmd)
-{
-	pmd_ERROR(*pmd);
-	pmd_clear(pmd);
-}
-
-/*
  * Note: this doesn't free the actual pages themselves. That
  * has been handled earlier when unmapping all the memory regions.
  */
diff --git a/mm/pgtable-generic.c b/mm/pgtable-generic.c
index e1a6e4f..3929a40 100644
--- a/mm/pgtable-generic.c
+++ b/mm/pgtable-generic.c
@@ -10,6 +10,30 @@
 #include <asm/tlb.h>
 #include <asm-generic/pgtable.h>
 
+/*
+ * If a p?d_bad entry is found while walking page tables, report
+ * the error, before resetting entry to p?d_none.  Usually (but
+ * very seldom) called out from the p?d_none_or_clear_bad macros.
+ */
+
+void pgd_clear_bad(pgd_t *pgd)
+{
+	pgd_ERROR(*pgd);
+	pgd_clear(pgd);
+}
+
+void pud_clear_bad(pud_t *pud)
+{
+	pud_ERROR(*pud);
+	pud_clear(pud);
+}
+
+void pmd_clear_bad(pmd_t *pmd)
+{
+	pmd_ERROR(*pmd);
+	pmd_clear(pmd);
+}
+
 #ifndef __HAVE_ARCH_PTEP_SET_ACCESS_FLAGS
 /*
  * Only sets the access flags (dirty, accessed), as well as write 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
