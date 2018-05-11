Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1A25A6B0677
	for <linux-mm@kvack.org>; Fri, 11 May 2018 14:04:35 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id x23-v6so3320746pfm.7
        for <linux-mm@kvack.org>; Fri, 11 May 2018 11:04:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k24-v6sor1165567pff.93.2018.05.11.11.04.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 11 May 2018 11:04:33 -0700 (PDT)
Date: Fri, 11 May 2018 23:36:39 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
Subject: [PATCH v2] mm: Change return type to vm_fault_t
Message-ID: <20180511180639.GA1792@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mhocko@suse.com, hughd@google.com, dan.j.williams@intel.com, rientjes@google.com, mike.kravetz@oracle.com, n-horiguchi@ah.jp.nec.com, aneesh.kumar@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, willy@infradead.org

Use new return type vm_fault_t for fault handler
in struct vm_operations_struct. For now, this is
just documenting that the function returns a 
VM_FAULT value rather than an errno.  Once all
instances are converted, vm_fault_t will become
a distinct type.

commit 1c8f422059ae ("mm: change return type to
vm_fault_t")

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Matthew Wilcox <mawilcox@microsoft.com>
---
v2: Updated the change log

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
