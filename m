Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 329106B002B
	for <linux-mm@kvack.org>; Sat, 14 Apr 2018 11:43:02 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id q15so6593146pff.15
        for <linux-mm@kvack.org>; Sat, 14 Apr 2018 08:43:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x22-v6sor3508351pln.60.2018.04.14.08.43.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 14 Apr 2018 08:43:00 -0700 (PDT)
Date: Sat, 14 Apr 2018 21:14:52 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH] mm: huge_memory: Change return type to vm_fault_t
Message-ID: <20180414154452.GA17964@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: willy@infradead.org

Use new return type vm_fault_t for vmf_insert_pfn_pud()
and vmf_insert_pfn_pmd()

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/huge_mm.h | 5 +++--
 mm/huge_memory.c        | 4 ++--
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index a8a1262..d3bbf6b 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -3,6 +3,7 @@
 #define _LINUX_HUGE_MM_H
 
 #include <linux/sched/coredump.h>
+#include <linux/mm_types.h>
 
 #include <linux/fs.h> /* only for vma_is_dax() */
 
@@ -46,9 +47,9 @@ extern bool move_huge_pmd(struct vm_area_struct *vma, unsigned long old_addr,
 extern int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
 			unsigned long addr, pgprot_t newprot,
 			int prot_numa);
-int vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
+vm_fault_t vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 			pmd_t *pmd, pfn_t pfn, bool write);
-int vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
+vm_fault_t vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
 			pud_t *pud, pfn_t pfn, bool write);
 enum transparent_hugepage_flag {
 	TRANSPARENT_HUGEPAGE_FLAG,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 87ab9b8..1fe4705 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -755,7 +755,7 @@ static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 	spin_unlock(ptl);
 }
 
-int vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
+vm_fault_t vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
 			pmd_t *pmd, pfn_t pfn, bool write)
 {
 	pgprot_t pgprot = vma->vm_page_prot;
@@ -815,7 +815,7 @@ static void insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
 	spin_unlock(ptl);
 }
 
-int vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
+vm_fault_t vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
 			pud_t *pud, pfn_t pfn, bool write)
 {
 	pgprot_t pgprot = vma->vm_page_prot;
-- 
1.9.1
