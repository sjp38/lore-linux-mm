From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 03/14] mm: remove FAULT_FLAG_RETRY dead code
Date: Tue, 07 Apr 2009 19:50:42 +0800
Message-ID: <20090407115234.083558981@intel.com>
References: <20090407115039.780820496@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E65D05F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 08:00:53 -0400 (EDT)
Content-Disposition: inline; filename=memory-fault-retry-simp.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ying Han <yinghan@google.com>, Wu Fengguang <fengguang.wu@intel.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hugh@veritas.com>, Ingo Molnar <mingo@elte.hu>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Mike Waychison <mikew@google.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rohit Seth <rohitseth@google.com>, Edwin <edwintorok@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-Id: linux-mm.kvack.org

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
