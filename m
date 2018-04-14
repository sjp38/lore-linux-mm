Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 58F946B0003
	for <linux-mm@kvack.org>; Sat, 14 Apr 2018 17:31:18 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id y7-v6so8021795plh.7
        for <linux-mm@kvack.org>; Sat, 14 Apr 2018 14:31:18 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a7sor2060177pgd.405.2018.04.14.14.31.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 14 Apr 2018 14:31:16 -0700 (PDT)
Date: Sun, 15 Apr 2018 03:03:07 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH] mm: Change return type to vm_fault_t
Message-ID: <20180414213307.GA23607@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: willy@infradead.org

Use new return type vm_fault_t for fault handlers.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 mm/hugetlb.c | 2 +-
 mm/mmap.c    | 4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 7c204e3..acb432a 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3158,7 +3158,7 @@ static int hugetlb_vm_op_split(struct vm_area_struct *vma, unsigned long addr)
  * hugegpage VMA.  do_page_fault() is supposed to trap this, so BUG is we get
  * this far.
  */
-static int hugetlb_vm_op_fault(struct vm_fault *vmf)
+static vm_fault_t hugetlb_vm_op_fault(struct vm_fault *vmf)
 {
 	BUG();
 	return 0;
diff --git a/mm/mmap.c b/mm/mmap.c
index 9efdc021..ac41b34 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3208,7 +3208,7 @@ void vm_stat_account(struct mm_struct *mm, vm_flags_t flags, long npages)
 		mm->data_vm += npages;
 }
 
-static int special_mapping_fault(struct vm_fault *vmf);
+static vm_fault_t special_mapping_fault(struct vm_fault *vmf);
 
 /*
  * Having a close hook prevents vma merging regardless of flags.
@@ -3247,7 +3247,7 @@ static int special_mapping_mremap(struct vm_area_struct *new_vma)
 	.fault = special_mapping_fault,
 };
 
-static int special_mapping_fault(struct vm_fault *vmf)
+static vm_fault_t special_mapping_fault(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	pgoff_t pgoff;
-- 
1.9.1
