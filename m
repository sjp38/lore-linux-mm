Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 36689828E1
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 18:55:51 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id n5so42199512pfn.2
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 15:55:51 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id e69si1448939pfd.66.2016.03.10.15.55.40
        for <linux-mm@kvack.org>;
        Thu, 10 Mar 2016 15:55:40 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v5 08/14] x86: Fix whitespace issues
Date: Thu, 10 Mar 2016 18:55:25 -0500
Message-Id: <1457654131-4562-9-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1457654131-4562-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1457654131-4562-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, x86@kernel.org, willy@linux.intel.com

checkpatch whines about these whitespace issues.  No code changes.

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 arch/x86/include/asm/pgtable-2level.h |  2 +-
 arch/x86/include/asm/pgtable.h        | 10 +++++-----
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/arch/x86/include/asm/pgtable-2level.h b/arch/x86/include/asm/pgtable-2level.h
index 520318f..2f558ba 100644
--- a/arch/x86/include/asm/pgtable-2level.h
+++ b/arch/x86/include/asm/pgtable-2level.h
@@ -11,7 +11,7 @@
  * within a page table are directly modified.  Thus, the following
  * hook is made available.
  */
-static inline void native_set_pte(pte_t *ptep , pte_t pte)
+static inline void native_set_pte(pte_t *ptep, pte_t pte)
 {
 	*ptep = pte;
 }
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 35306ca..4cbc459 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -746,13 +746,13 @@ static inline pmd_t native_local_pmdp_get_and_clear(pmd_t *pmdp)
 #endif
 
 static inline void native_set_pte_at(struct mm_struct *mm, unsigned long addr,
-				     pte_t *ptep , pte_t pte)
+				     pte_t *ptep, pte_t pte)
 {
 	native_set_pte(ptep, pte);
 }
 
 static inline void native_set_pmd_at(struct mm_struct *mm, unsigned long addr,
-				     pmd_t *pmdp , pmd_t pmd)
+				     pmd_t *pmdp, pmd_t pmd)
 {
 	native_set_pmd(pmdp, pmd);
 }
@@ -852,8 +852,8 @@ static inline int pmd_write(pmd_t pmd)
 }
 
 #define __HAVE_ARCH_PMDP_HUGE_GET_AND_CLEAR
-static inline pmd_t pmdp_huge_get_and_clear(struct mm_struct *mm, unsigned long addr,
-				       pmd_t *pmdp)
+static inline pmd_t pmdp_huge_get_and_clear(struct mm_struct *mm,
+					unsigned long addr, pmd_t *pmdp)
 {
 	return native_pmdp_get_and_clear(pmdp);
 }
@@ -877,7 +877,7 @@ static inline void pmdp_set_wrprotect(struct mm_struct *mm,
  */
 static inline void clone_pgd_range(pgd_t *dst, pgd_t *src, int count)
 {
-       memcpy(dst, src, count * sizeof(pgd_t));
+	memcpy(dst, src, count * sizeof(pgd_t));
 }
 
 #define PTE_SHIFT ilog2(PTRS_PER_PTE)
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
