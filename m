Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A1B2A6B0012
	for <linux-mm@kvack.org>; Fri, 17 Jun 2011 04:30:15 -0400 (EDT)
Received: by iyl8 with SMTP id 8so2461869iyl.14
        for <linux-mm@kvack.org>; Fri, 17 Jun 2011 01:30:12 -0700 (PDT)
From: Chris Forbes <chrisf@ijw.co.nz>
Subject: [PATCH] mm: hugetlb: fix coding style issues
Date: Fri, 17 Jun 2011 20:29:59 +1200
Message-Id: <1308299399-825-1-git-send-email-chrisf@ijw.co.nz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Chris Forbes <chrisf@ijw.co.nz>

Fixed coding style issues flagged by checkpatch.pl

Signed-off-by: Chris Forbes <chrisf@ijw.co.nz>
---
 mm/hugetlb.c |   31 +++++++++++++++----------------
 1 files changed, 15 insertions(+), 16 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index bfcf153..ab8bd93e 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -24,7 +24,7 @@
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
-#include <asm/io.h>
+#include <linux/io.h>
 
 #include <linux/hugetlb.h>
 #include <linux/node.h>
@@ -62,10 +62,10 @@ static DEFINE_SPINLOCK(hugetlb_lock);
  * must either hold the mmap_sem for write, or the mmap_sem for read and
  * the hugetlb_instantiation mutex:
  *
- * 	down_write(&mm->mmap_sem);
+ *	down_write(&mm->mmap_sem);
  * or
- * 	down_read(&mm->mmap_sem);
- * 	mutex_lock(&hugetlb_instantiation_mutex);
+ *	down_read(&mm->mmap_sem);
+ *	mutex_lock(&hugetlb_instantiation_mutex);
  */
 struct file_region {
 	struct list_head link;
@@ -503,9 +503,10 @@ static void update_and_free_page(struct hstate *h, struct page *page)
 	h->nr_huge_pages--;
 	h->nr_huge_pages_node[page_to_nid(page)]--;
 	for (i = 0; i < pages_per_huge_page(h); i++) {
-		page[i].flags &= ~(1 << PG_locked | 1 << PG_error | 1 << PG_referenced |
-				1 << PG_dirty | 1 << PG_active | 1 << PG_reserved |
-				1 << PG_private | 1<< PG_writeback);
+		page[i].flags &= ~(1 << PG_locked | 1 << PG_error |
+				1 << PG_referenced | 1 << PG_dirty |
+				1 << PG_active | 1 << PG_reserved |
+				1 << PG_private | 1 << PG_writeback);
 	}
 	set_compound_page_dtor(page, NULL);
 	set_page_refcounted(page);
@@ -591,7 +592,6 @@ int PageHuge(struct page *page)
 
 	return dtor == free_huge_page;
 }
-
 EXPORT_SYMBOL_GPL(PageHuge);
 
 static struct page *alloc_fresh_huge_page_node(struct hstate *h, int nid)
@@ -2124,9 +2124,8 @@ static void set_huge_ptep_writable(struct vm_area_struct *vma,
 	pte_t entry;
 
 	entry = pte_mkwrite(pte_mkdirty(huge_ptep_get(ptep)));
-	if (huge_ptep_set_access_flags(vma, address, ptep, entry, 1)) {
+	if (huge_ptep_set_access_flags(vma, address, ptep, entry, 1))
 		update_mmu_cache(vma, address, ptep);
-	}
 }
 
 
@@ -2181,9 +2180,9 @@ static int is_hugetlb_entry_migration(pte_t pte)
 	if (huge_pte_none(pte) || pte_present(pte))
 		return 0;
 	swp = pte_to_swp_entry(pte);
-	if (non_swap_entry(swp) && is_migration_entry(swp)) {
+	if (non_swap_entry(swp) && is_migration_entry(swp))
 		return 1;
-	} else
+	else
 		return 0;
 }
 
@@ -2194,9 +2193,9 @@ static int is_hugetlb_entry_hwpoisoned(pte_t pte)
 	if (huge_pte_none(pte) || pte_present(pte))
 		return 0;
 	swp = pte_to_swp_entry(pte);
-	if (non_swap_entry(swp) && is_hwpoison_entry(swp)) {
+	if (non_swap_entry(swp) && is_hwpoison_entry(swp))
 		return 1;
-	} else
+	else
 		return 0;
 }
 
@@ -2559,7 +2558,7 @@ retry:
 		 * So we need to block hugepage fault by PG_hwpoison bit check.
 		 */
 		if (unlikely(PageHWPoison(page))) {
-			ret = VM_FAULT_HWPOISON | 
+			ret = VM_FAULT_HWPOISON |
 			      VM_FAULT_SET_HINDEX(h - hstates);
 			goto backout_unlocked;
 		}
@@ -2627,7 +2626,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			migration_entry_wait(mm, (pmd_t *)ptep, address);
 			return 0;
 		} else if (unlikely(is_hugetlb_entry_hwpoisoned(entry)))
-			return VM_FAULT_HWPOISON_LARGE | 
+			return VM_FAULT_HWPOISON_LARGE |
 			       VM_FAULT_SET_HINDEX(h - hstates);
 	}
 
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
