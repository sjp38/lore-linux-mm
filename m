Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 0FD4B90010D
	for <linux-mm@kvack.org>; Sun, 15 May 2011 18:22:35 -0400 (EDT)
From: Stephen Wilson <wilsons@start.ca>
Subject: [PATCH v2 5/9] mm: remove check_huge_range()
Date: Sun, 15 May 2011 18:20:25 -0400
Message-Id: <1305498029-11677-6-git-send-email-wilsons@start.ca>
In-Reply-To: <1305498029-11677-1-git-send-email-wilsons@start.ca>
References: <1305498029-11677-1-git-send-email-wilsons@start.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Stephen Wilson <wilsons@start.ca>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Alexey Dobriyan <adobriyan@gmail.com>, Christoph Lameter <cl@linux-foundation.org>

This function has been superseded by gather_hugetbl_stats() and is no
longer needed.

Signed-off-by: Stephen Wilson <wilsons@start.ca>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: Alexey Dobriyan <adobriyan@gmail.com>
Cc: Christoph Lameter <cl@linux-foundation.org>
---
 mm/mempolicy.c |   35 -----------------------------------
 1 files changed, 0 insertions(+), 35 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 108f858..231efc8 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2616,35 +2616,6 @@ static int gather_pte_stats(pmd_t *pmd, unsigned long addr,
 }
 
 #ifdef CONFIG_HUGETLB_PAGE
-static void check_huge_range(struct vm_area_struct *vma,
-		unsigned long start, unsigned long end,
-		struct numa_maps *md)
-{
-	unsigned long addr;
-	struct page *page;
-	struct hstate *h = hstate_vma(vma);
-	unsigned long sz = huge_page_size(h);
-
-	for (addr = start; addr < end; addr += sz) {
-		pte_t *ptep = huge_pte_offset(vma->vm_mm,
-						addr & huge_page_mask(h));
-		pte_t pte;
-
-		if (!ptep)
-			continue;
-
-		pte = *ptep;
-		if (pte_none(pte))
-			continue;
-
-		page = pte_page(pte);
-		if (!page)
-			continue;
-
-		gather_stats(page, md, pte_dirty(*ptep));
-	}
-}
-
 static int gather_hugetbl_stats(pte_t *pte, unsigned long hmask,
 		unsigned long addr, unsigned long end, struct mm_walk *walk)
 {
@@ -2664,12 +2635,6 @@ static int gather_hugetbl_stats(pte_t *pte, unsigned long hmask,
 }
 
 #else
-static inline void check_huge_range(struct vm_area_struct *vma,
-		unsigned long start, unsigned long end,
-		struct numa_maps *md)
-{
-}
-
 static int gather_hugetbl_stats(pte_t *pte, unsigned long hmask,
 		unsigned long addr, unsigned long end, struct mm_walk *walk)
 {
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
