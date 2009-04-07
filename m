Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 19AE55F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 03:45:05 -0400 (EDT)
Message-Id: <20090407072133.053995305@intel.com>
References: <20090407071729.233579162@intel.com>
Date: Tue, 07 Apr 2009 15:17:32 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 03/14] mm: remove FAULT_FLAG_RETRY dead code
Content-Disposition: inline; filename=memory-fault-retry-simp.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ying Han <yinghan@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

Cc: Ying Han <yinghan@google.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/memory.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

--- mm.orig/mm/memory.c
+++ mm/mm/memory.c
@@ -2766,10 +2766,8 @@ static int do_linear_fault(struct mm_str
 {
 	pgoff_t pgoff = (((address & PAGE_MASK)
 			- vma->vm_start) >> PAGE_SHIFT) + vma->vm_pgoff;
-	int write = write_access & ~FAULT_FLAG_RETRY;
-	unsigned int flags = (write ? FAULT_FLAG_WRITE : 0);
+	unsigned int flags = (write_access ? FAULT_FLAG_WRITE : 0);
 
-	flags |= (write_access & FAULT_FLAG_RETRY);
 	pte_unmap(page_table);
 	return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
 }

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
