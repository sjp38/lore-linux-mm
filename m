Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 538BE6B0025
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 19:37:06 -0400 (EDT)
From: Stephen Wilson <wilsons@start.ca>
Subject: [PATCH 5/8] mm: remove check_huge_range()
Date: Wed, 27 Apr 2011 19:35:46 -0400
Message-Id: <1303947349-3620-6-git-send-email-wilsons@start.ca>
In-Reply-To: <1303947349-3620-1-git-send-email-wilsons@start.ca>
References: <1303947349-3620-1-git-send-email-wilsons@start.ca>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This function has been superseded by gather_hugetbl_stats() and is no
longer needed.

Signed-off-by: Stephen Wilson <wilsons@start.ca>
---
 mm/mempolicy.c |   35 -----------------------------------
 1 files changed, 0 insertions(+), 35 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index d4c0b8d..c5a4342 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2587,35 +2587,6 @@ static int gather_pte_stats(pte_t *pte, unsigned long addr,
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
@@ -2635,12 +2606,6 @@ static int gather_hugetbl_stats(pte_t *pte, unsigned long hmask,
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
1.7.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
