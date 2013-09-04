Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id B55B96B0039
	for <linux-mm@kvack.org>; Wed,  4 Sep 2013 12:50:25 -0400 (EDT)
Date: Wed, 04 Sep 2013 12:50:23 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1378313423-9sbygyow-mutt-n-horiguchi@ah.jp.nec.com>
Subject: [PATCH] mm: remove obsolete comments about page table lock
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org

The callers of free_pgd_range() and hugetlb_free_pgd_range() don't hold
page table locks. The comments seems to be obsolete, so let's remove them.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 arch/powerpc/mm/hugetlbpage.c | 2 --
 mm/memory.c                   | 2 --
 2 files changed, 4 deletions(-)

diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index 7e56cb7..31c20e2 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -635,8 +635,6 @@ static void hugetlb_free_pud_range(struct mmu_gather *tlb, pgd_t *pgd,
 
 /*
  * This function frees user-level page tables of a process.
- *
- * Must be called with pagetable lock held.
  */
 void hugetlb_free_pgd_range(struct mmu_gather *tlb,
 			    unsigned long addr, unsigned long end,
diff --git a/mm/memory.c b/mm/memory.c
index 6827a35..8c97ef0 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -478,8 +478,6 @@ static inline void free_pud_range(struct mmu_gather *tlb, pgd_t *pgd,
 
 /*
  * This function frees user-level page tables of a process.
- *
- * Must be called with pagetable lock held.
  */
 void free_pgd_range(struct mmu_gather *tlb,
 			unsigned long addr, unsigned long end,
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
