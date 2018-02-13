Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 436C16B0003
	for <linux-mm@kvack.org>; Tue, 13 Feb 2018 14:17:46 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id i12so11269002wra.22
        for <linux-mm@kvack.org>; Tue, 13 Feb 2018 11:17:46 -0800 (PST)
Received: from mout.web.de (mout.web.de. [217.72.192.78])
        by mx.google.com with ESMTPS id h28si1098761wrb.51.2018.02.13.11.17.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Feb 2018 11:17:45 -0800 (PST)
From: Mario Leinweber <marioleinweber@web.de>
Subject: [PATCH] mm/gup: Fixed coding style error and warnings.
Date: Tue, 13 Feb 2018 14:17:22 -0500
Message-Id: <20180213191722.11228-1-marioleinweber@web.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mingo@kernel.org, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mario Leinweber <marioleinweber@web.de>

Signed-off-by: Mario Leinweber <marioleinweber@web.de>
---
 mm/gup.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index 1b46e6e74881..7e463042df4a 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -141,6 +141,7 @@ static struct page *follow_page_pte(struct vm_area_struct *vma,
 
 	if (flags & FOLL_SPLIT && PageTransCompound(page)) {
 		int ret;
+
 		get_page(page);
 		pte_unmap_unlock(ptep, ptl);
 		lock_page(page);
@@ -272,6 +273,7 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
 	}
 	if (flags & FOLL_SPLIT) {
 		int ret;
+
 		page = pmd_page(*pmd);
 		if (is_huge_zero_page(page)) {
 			spin_unlock(ptl);
@@ -531,7 +533,7 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
 	 * reCOWed by userspace write).
 	 */
 	if ((ret & VM_FAULT_WRITE) && !(vma->vm_flags & VM_WRITE))
-	        *flags |= FOLL_COW;
+		*flags |= FOLL_COW;
 	return 0;
 }
 
@@ -667,12 +669,14 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 			vma = find_extend_vma(mm, start);
 			if (!vma && in_gate_area(mm, start)) {
 				int ret;
+
 				ret = get_gate_page(mm, start & PAGE_MASK,
 						gup_flags, &vma,
 						pages ? &pages[i] : NULL);
 				if (ret)
 					return i ? : ret;
 				page_mask = 0;
+
 				goto next_page;
 			}
 
@@ -696,6 +700,7 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		page = follow_page_mask(vma, start, foll_flags, &page_mask);
 		if (!page) {
 			int ret;
+
 			ret = faultin_page(tsk, vma, start, &foll_flags,
 					nonblocking);
 			switch (ret) {
@@ -1635,7 +1640,7 @@ static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
 					 PMD_SHIFT, next, write, pages, nr))
 				return 0;
 		} else if (!gup_pte_range(pmd, addr, next, write, pages, nr))
-				return 0;
+			return 0;
 	} while (pmdp++, addr = next, addr != end);
 
 	return 1;
-- 
2.14.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
