Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 20FDB6B006C
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 01:54:39 -0500 (EST)
Subject: [patch v2 2/4]thp: remove unnecessary tlb flush for mprotect
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 15 Nov 2011 15:04:13 +0800
Message-ID: <1321340653.22361.295.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm <linux-mm@kvack.org>

change_protection() will do TLB flush later, don't need duplicate tlb flush.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/huge_memory.c |    1 -
 1 file changed, 1 deletion(-)

Index: linux/mm/huge_memory.c
===================================================================
--- linux.orig/mm/huge_memory.c	2011-11-14 16:14:08.000000000 +0800
+++ linux/mm/huge_memory.c	2011-11-14 16:14:33.000000000 +0800
@@ -1145,7 +1145,6 @@ int change_huge_pmd(struct vm_area_struc
 			entry = pmd_modify(entry, newprot);
 			set_pmd_at(mm, addr, pmd, entry);
 			spin_unlock(&vma->vm_mm->page_table_lock);
-			flush_tlb_range(vma, addr, addr + HPAGE_PMD_SIZE);
 			ret = 1;
 		}
 	} else


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
