Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 433246B003A
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 15:41:18 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id x10so6535367pdj.22
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 12:41:17 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id to9si16561741pbc.185.2014.02.10.12.41.16
        for <linux-mm@kvack.org>;
        Mon, 10 Feb 2014 12:41:17 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/8] mm: rename __do_fault() -> do_fault()
Date: Mon, 10 Feb 2014 22:41:00 +0200
Message-Id: <1392064866-11840-3-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1392064866-11840-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1392064866-11840-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>
Cc: Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

do_fault() is unused: no reason for underscores.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/memory.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 5f2001a7ab31..e626283089ca 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2748,7 +2748,7 @@ reuse:
 		 * bit after it clear all dirty ptes, but before a racing
 		 * do_wp_page installs a dirty pte.
 		 *
-		 * __do_fault is protected similarly.
+		 * do_fault is protected similarly.
 		 */
 		if (!page_mkwrite) {
 			wait_on_page_locked(dirty_page);
@@ -3287,7 +3287,7 @@ oom:
 }
 
 /*
- * __do_fault() tries to create a new page mapping. It aggressively
+ * do_fault() tries to create a new page mapping. It aggressively
  * tries to share with existing pages, but makes a separate copy if
  * the FAULT_FLAG_WRITE is set in the flags parameter in order to avoid
  * the next page fault.
@@ -3299,7 +3299,7 @@ oom:
  * but allow concurrent faults), and pte neither mapped nor locked.
  * We return with mmap_sem still held, but pte unmapped and unlocked.
  */
-static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
+static int do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pmd_t *pmd,
 		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
 {
@@ -3496,7 +3496,7 @@ static int do_linear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 			- vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
 
 	pte_unmap(page_table);
-	return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
+	return do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
 }
 
 /*
@@ -3528,7 +3528,7 @@ static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 
 	pgoff = pte_to_pgoff(orig_pte);
-	return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
+	return do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
 }
 
 int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
-- 
1.8.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
