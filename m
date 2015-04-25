Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id D265C6B0032
	for <linux-mm@kvack.org>; Fri, 24 Apr 2015 23:49:51 -0400 (EDT)
Received: by oblw8 with SMTP id w8so51278122obl.0
        for <linux-mm@kvack.org>; Fri, 24 Apr 2015 20:49:51 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id du5si9586920oeb.102.2015.04.24.20.49.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 24 Apr 2015 20:49:50 -0700 (PDT)
Message-ID: <553B0D57.2090108@huawei.com>
Date: Sat, 25 Apr 2015 11:43:19 +0800
From: Zhang Zhen <zhenzhang.zhang@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mm/hugetlb: reduce arch dependent code about hugetlb_prefault_arch_hook
References: <1429933043-56833-1-git-send-email-zhenzhang.zhang@huawei.com>
In-Reply-To: <1429933043-56833-1-git-send-email-zhenzhang.zhang@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, nyc@holomorphy.com, anthony.iliopoulos@huawei.com, tony.luck@intel.com, Dave Hansen <dave.hansen@intel.com>, steve.capper@linaro.org
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

Currently we have many duplicates in definitions of hugetlb_prefault_arch_hook.
In all architectures this function is empty.

Signed-off-by: Zhang Zhen <zhenzhang.zhang@huawei.com>
---
 arch/arm/include/asm/hugetlb.h     | 4 ----
 arch/arm64/include/asm/hugetlb.h   | 4 ----
 arch/ia64/include/asm/hugetlb.h    | 4 ----
 arch/metag/include/asm/hugetlb.h   | 4 ----
 arch/mips/include/asm/hugetlb.h    | 4 ----
 arch/powerpc/include/asm/hugetlb.h | 5 -----
 arch/s390/include/asm/hugetlb.h    | 1 -
 arch/sh/include/asm/hugetlb.h      | 3 ---
 arch/sparc/include/asm/hugetlb.h   | 4 ----
 arch/tile/include/asm/hugetlb.h    | 4 ----
 arch/x86/include/asm/hugetlb.h     | 3 ---
 fs/hugetlbfs/inode.c               | 1 -
 12 files changed, 41 deletions(-)

diff --git a/arch/arm/include/asm/hugetlb.h b/arch/arm/include/asm/hugetlb.h
index 1f1b1cd..31bb7dc 100644
--- a/arch/arm/include/asm/hugetlb.h
+++ b/arch/arm/include/asm/hugetlb.h
@@ -53,10 +53,6 @@ static inline int prepare_hugepage_range(struct file *file,
 	return 0;
 }

-static inline void hugetlb_prefault_arch_hook(struct mm_struct *mm)
-{
-}
-
 static inline int huge_pte_none(pte_t pte)
 {
 	return pte_none(pte);
diff --git a/arch/arm64/include/asm/hugetlb.h b/arch/arm64/include/asm/hugetlb.h
index 5b7ca8a..734c17e 100644
--- a/arch/arm64/include/asm/hugetlb.h
+++ b/arch/arm64/include/asm/hugetlb.h
@@ -86,10 +86,6 @@ static inline int prepare_hugepage_range(struct file *file,
 	return 0;
 }

-static inline void hugetlb_prefault_arch_hook(struct mm_struct *mm)
-{
-}
-
 static inline int huge_pte_none(pte_t pte)
 {
 	return pte_none(pte);
diff --git a/arch/ia64/include/asm/hugetlb.h b/arch/ia64/include/asm/hugetlb.h
index aa91005..ff1377b 100644
--- a/arch/ia64/include/asm/hugetlb.h
+++ b/arch/ia64/include/asm/hugetlb.h
@@ -20,10 +20,6 @@ static inline int is_hugepage_only_range(struct mm_struct *mm,
 		REGION_NUMBER((addr)+(len)-1) == RGN_HPAGE);
 }

-static inline void hugetlb_prefault_arch_hook(struct mm_struct *mm)
-{
-}
-
 static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 				   pte_t *ptep, pte_t pte)
 {
diff --git a/arch/metag/include/asm/hugetlb.h b/arch/metag/include/asm/hugetlb.h
index 471f481..f730b39 100644
--- a/arch/metag/include/asm/hugetlb.h
+++ b/arch/metag/include/asm/hugetlb.h
@@ -14,10 +14,6 @@ static inline int is_hugepage_only_range(struct mm_struct *mm,
 int prepare_hugepage_range(struct file *file, unsigned long addr,
 						unsigned long len);

-static inline void hugetlb_prefault_arch_hook(struct mm_struct *mm)
-{
-}
-
 static inline void hugetlb_free_pgd_range(struct mmu_gather *tlb,
 					  unsigned long addr, unsigned long end,
 					  unsigned long floor,
diff --git a/arch/mips/include/asm/hugetlb.h b/arch/mips/include/asm/hugetlb.h
index fe0d15d..4a5bb54 100644
--- a/arch/mips/include/asm/hugetlb.h
+++ b/arch/mips/include/asm/hugetlb.h
@@ -38,10 +38,6 @@ static inline int prepare_hugepage_range(struct file *file,
 	return 0;
 }

-static inline void hugetlb_prefault_arch_hook(struct mm_struct *mm)
-{
-}
-
 static inline void hugetlb_free_pgd_range(struct mmu_gather *tlb,
 					  unsigned long addr,
 					  unsigned long end,
diff --git a/arch/powerpc/include/asm/hugetlb.h b/arch/powerpc/include/asm/hugetlb.h
index 1d53a65..4bbd3c8 100644
--- a/arch/powerpc/include/asm/hugetlb.h
+++ b/arch/powerpc/include/asm/hugetlb.h
@@ -112,11 +112,6 @@ static inline int prepare_hugepage_range(struct file *file,
 	return 0;
 }

-static inline void hugetlb_prefault_arch_hook(struct mm_struct *mm)
-{
-}
-
-
 static inline void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 				   pte_t *ptep, pte_t pte)
 {
diff --git a/arch/s390/include/asm/hugetlb.h b/arch/s390/include/asm/hugetlb.h
index 11eae5f..dfb542a 100644
--- a/arch/s390/include/asm/hugetlb.h
+++ b/arch/s390/include/asm/hugetlb.h
@@ -35,7 +35,6 @@ static inline int prepare_hugepage_range(struct file *file,
 	return 0;
 }

-#define hugetlb_prefault_arch_hook(mm)		do { } while (0)
 #define arch_clear_hugepage_flags(page)		do { } while (0)

 int arch_prepare_hugepage(struct page *page);
diff --git a/arch/sh/include/asm/hugetlb.h b/arch/sh/include/asm/hugetlb.h
index 699255d..b788a9b 100644
--- a/arch/sh/include/asm/hugetlb.h
+++ b/arch/sh/include/asm/hugetlb.h
@@ -26,9 +26,6 @@ static inline int prepare_hugepage_range(struct file *file,
 	return 0;
 }

-static inline void hugetlb_prefault_arch_hook(struct mm_struct *mm) {
-}
-
 static inline void hugetlb_free_pgd_range(struct mmu_gather *tlb,
 					  unsigned long addr, unsigned long end,
 					  unsigned long floor,
diff --git a/arch/sparc/include/asm/hugetlb.h b/arch/sparc/include/asm/hugetlb.h
index e4cab46..3130d76 100644
--- a/arch/sparc/include/asm/hugetlb.h
+++ b/arch/sparc/include/asm/hugetlb.h
@@ -11,10 +11,6 @@ void set_huge_pte_at(struct mm_struct *mm, unsigned long addr,
 pte_t huge_ptep_get_and_clear(struct mm_struct *mm, unsigned long addr,
 			      pte_t *ptep);

-static inline void hugetlb_prefault_arch_hook(struct mm_struct *mm)
-{
-}
-
 static inline int is_hugepage_only_range(struct mm_struct *mm,
 					 unsigned long addr,
 					 unsigned long len) {
diff --git a/arch/tile/include/asm/hugetlb.h b/arch/tile/include/asm/hugetlb.h
index 3257733..1abd00c 100644
--- a/arch/tile/include/asm/hugetlb.h
+++ b/arch/tile/include/asm/hugetlb.h
@@ -40,10 +40,6 @@ static inline int prepare_hugepage_range(struct file *file,
 	return 0;
 }

-static inline void hugetlb_prefault_arch_hook(struct mm_struct *mm)
-{
-}
-
 static inline void hugetlb_free_pgd_range(struct mmu_gather *tlb,
 					  unsigned long addr, unsigned long end,
 					  unsigned long floor,
diff --git a/arch/x86/include/asm/hugetlb.h b/arch/x86/include/asm/hugetlb.h
index 68c0539..dab7a3a 100644
--- a/arch/x86/include/asm/hugetlb.h
+++ b/arch/x86/include/asm/hugetlb.h
@@ -26,9 +26,6 @@ static inline int prepare_hugepage_range(struct file *file,
 	return 0;
 }

-static inline void hugetlb_prefault_arch_hook(struct mm_struct *mm) {
-}
-
 static inline void hugetlb_free_pgd_range(struct mmu_gather *tlb,
 					  unsigned long addr, unsigned long end,
 					  unsigned long floor,
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 2640d88..f45ea95 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -130,7 +130,6 @@ static int hugetlbfs_file_mmap(struct file *file, struct vm_area_struct *vma)
 		goto out;

 	ret = 0;
-	hugetlb_prefault_arch_hook(vma->vm_mm);
 	if (vma->vm_flags & VM_WRITE && inode->i_size < len)
 		inode->i_size = len;
 out:
-- 
1.9.1


.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
