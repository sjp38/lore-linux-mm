Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7C3A66B0261
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 18:38:04 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id h53so213269125qth.6
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 15:38:04 -0800 (PST)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id x54si15555050qtc.110.2017.02.01.15.38.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Feb 2017 15:38:03 -0800 (PST)
From: "Tobin C. Harding" <me@tobin.cc>
Subject: [PATCH 3/4] mm: Fix checkpatch errors, whitespace errors
Date: Thu,  2 Feb 2017 10:37:19 +1100
Message-Id: <1485992240-10986-4-git-send-email-me@tobin.cc>
In-Reply-To: <1485992240-10986-1-git-send-email-me@tobin.cc>
References: <1485992240-10986-1-git-send-email-me@tobin.cc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Tobin C Harding <me@tobin.cc>

From: Tobin C Harding <me@tobin.cc>

Patch fixes whitespace checkpatch errors.

Signed-off-by: Tobin C Harding <me@tobin.cc>
---
 mm/memory.c | 42 +++++++++++++++++++++---------------------
 1 file changed, 21 insertions(+), 21 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 3562314..35fb8b2 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -95,7 +95,7 @@ EXPORT_SYMBOL(mem_map);
  * highstart_pfn must be the same; there must be no gap between ZONE_NORMAL
  * and ZONE_HIGHMEM.
  */
-void * high_memory;
+void *high_memory;
 EXPORT_SYMBOL(high_memory);
 
 /*
@@ -555,7 +555,7 @@ void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *vma,
 
 		if (is_vm_hugetlb_page(vma)) {
 			hugetlb_free_pgd_range(tlb, addr, vma->vm_end,
-				floor, next? next->vm_start: ceiling);
+				floor, next ? next->vm_start : ceiling);
 		} else {
 			/*
 			 * Optimization: gather nearby vmas into one call down
@@ -568,7 +568,7 @@ void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *vma,
 				unlink_file_vma(vma);
 			}
 			free_pgd_range(tlb, addr, vma->vm_end,
-				floor, next? next->vm_start: ceiling);
+				floor, next ? next->vm_start : ceiling);
 		}
 		vma = next;
 	}
@@ -1447,10 +1447,10 @@ EXPORT_SYMBOL_GPL(zap_vma_ptes);
 pte_t *__get_locked_pte(struct mm_struct *mm, unsigned long addr,
 			spinlock_t **ptl)
 {
-	pgd_t * pgd = pgd_offset(mm, addr);
-	pud_t * pud = pud_alloc(mm, pgd, addr);
+	pgd_t *pgd = pgd_offset(mm, addr);
+	pud_t *pud = pud_alloc(mm, pgd, addr);
 	if (pud) {
-		pmd_t * pmd = pmd_alloc(mm, pud, addr);
+		pmd_t *pmd = pmd_alloc(mm, pud, addr);
 		if (pmd) {
 			VM_BUG_ON(pmd_trans_huge(*pmd));
 			return pte_alloc_map_lock(mm, pmd, addr, ptl);
@@ -2509,7 +2509,7 @@ void unmap_mapping_range(struct address_space *mapping,
 			hlen = ULONG_MAX - hba + 1;
 	}
 
-	details.check_mapping = even_cows? NULL: mapping;
+	details.check_mapping = even_cows ? NULL : mapping;
 	details.first_index = hba;
 	details.last_index = hba + hlen - 1;
 	if (details.last_index < details.first_index)
@@ -3391,14 +3391,14 @@ static int do_numa_page(struct vm_fault *vmf)
 	int flags = 0;
 
 	/*
-	* The "pte" at this point cannot be used safely without
-	* validation through pte_unmap_same(). It's of NUMA type but
-	* the pfn may be screwed if the read is non atomic.
-	*
-	* We can safely just do a "set_pte_at()", because the old
-	* page table entry is not accessible, so there would be no
-	* concurrent hardware modifications to the PTE.
-	*/
+	 * The "pte" at this point cannot be used safely without
+	 * validation through pte_unmap_same(). It's of NUMA type but
+	 * the pfn may be screwed if the read is non atomic.
+	 *
+	 * We can safely just do a "set_pte_at()", because the old
+	 * page table entry is not accessible, so there would be no
+	 * concurrent hardware modifications to the PTE.
+	 */
 	vmf->ptl = pte_lockptr(vma->vm_mm, vmf->pmd);
 	spin_lock(vmf->ptl);
 	if (unlikely(!pte_same(*vmf->pte, pte))) {
@@ -3689,12 +3689,12 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
 
 	if (flags & FAULT_FLAG_USER) {
 		mem_cgroup_oom_disable();
-                /*
-                 * The task may have entered a memcg OOM situation but
-                 * if the allocation error was handled gracefully (no
-                 * VM_FAULT_OOM), there is no need to kill anything.
-                 * Just clean up the OOM state peacefully.
-                 */
+		/*
+		 * The task may have entered a memcg OOM situation but
+		 * if the allocation error was handled gracefully (no
+		 * VM_FAULT_OOM), there is no need to kill anything.
+		 * Just clean up the OOM state peacefully.
+		 */
 		if (task_in_memcg_oom(current) && !(ret & VM_FAULT_OOM))
 			mem_cgroup_oom_synchronize(false);
 	}
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
