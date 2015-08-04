Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id E63F56B025B
	for <linux-mm@kvack.org>; Tue,  4 Aug 2015 15:58:28 -0400 (EDT)
Received: by pawu10 with SMTP id u10so16018392paw.1
        for <linux-mm@kvack.org>; Tue, 04 Aug 2015 12:58:28 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id x8si815737pde.111.2015.08.04.12.58.13
        for <linux-mm@kvack.org>;
        Tue, 04 Aug 2015 12:58:13 -0700 (PDT)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 11/11] dax: Use linear_page_index()
Date: Tue,  4 Aug 2015 15:58:05 -0400
Message-Id: <1438718285-21168-12-git-send-email-matthew.r.wilcox@intel.com>
In-Reply-To: <1438718285-21168-1-git-send-email-matthew.r.wilcox@intel.com>
References: <1438718285-21168-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Matthew Wilcox <willy@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

I was basically open-coding it (thanks to copying code from do_fault()
which probably also needs to be fixed).

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 fs/dax.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/dax.c b/fs/dax.c
index 233e61e..b6769ce 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -529,7 +529,7 @@ int __dax_pmd_fault(struct vm_area_struct *vma, unsigned long address,
 	if ((pmd_addr + PMD_SIZE) > vma->vm_end)
 		return VM_FAULT_FALLBACK;
 
-	pgoff = ((pmd_addr - vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
+	pgoff = linear_page_index(vma, pmd_addr);
 	size = (i_size_read(inode) + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	if (pgoff >= size)
 		return VM_FAULT_SIGBUS;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
