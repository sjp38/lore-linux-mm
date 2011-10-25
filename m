Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 66E306B002E
	for <linux-mm@kvack.org>; Mon, 24 Oct 2011 22:51:51 -0400 (EDT)
Subject: [patch 2/5]thp: remove unnecessary tlb flush for mprotect
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 25 Oct 2011 10:59:25 +0800
Message-ID: <1319511565.22361.138.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: aarcange@redhat.com, Hugh Dickins <hughd@google.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

change_protection() will do TLB flush later, don't need duplicate tlb flush.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>
---
 mm/huge_memory.c |    1 -
 1 file changed, 1 deletion(-)

Index: linux/mm/huge_memory.c
===================================================================
--- linux.orig/mm/huge_memory.c	2011-10-24 19:24:31.000000000 +0800
+++ linux/mm/huge_memory.c	2011-10-24 19:25:10.000000000 +0800
@@ -1079,7 +1079,6 @@ int change_huge_pmd(struct vm_area_struc
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
