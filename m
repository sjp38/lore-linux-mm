Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id EB0126B0096
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:09:06 -0500 (EST)
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id o1QK9533004864
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 15:09:05 -0500
Message-Id: <20100226200903.331170307@redhat.com>
Date: Fri, 26 Feb 2010 21:05:01 +0100
From: aarcange@redhat.com
Subject: [patch 28/35] adapt to mm_counter in -mm
References: <20100226200433.516502198@redhat.com>
Content-Disposition: inline; filename=mm-rss
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

From: Andrea Arcangeli <aarcange@redhat.com>

The interface changed slightly.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Rik van Riel <riel@redhat.com>
---
 mm/huge_memory.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -251,7 +251,7 @@ static int __do_huge_pmd_anonymous_page(
 		page_add_new_anon_rmap(page, vma, haddr);
 		set_pmd_at(mm, haddr, pmd, entry);
 		prepare_pmd_huge_pte(pgtable, mm);
-		add_mm_counter(mm, anon_rss, HPAGE_PMD_NR);
+		add_mm_counter(mm, MM_ANONPAGES, HPAGE_PMD_NR);
 		spin_unlock(&mm->page_table_lock);
 	}
 
@@ -321,7 +321,7 @@ int copy_huge_pmd(struct mm_struct *dst_
 	VM_BUG_ON(!PageHead(src_page));
 	get_page(src_page);
 	page_dup_rmap(src_page);
-	add_mm_counter(dst_mm, anon_rss, HPAGE_PMD_NR);
+	add_mm_counter(dst_mm, MM_ANONPAGES, HPAGE_PMD_NR);
 
 	pmdp_set_wrprotect(src_mm, addr, src_pmd);
 	pmd = pmd_mkold(pmd_wrprotect(pmd));
@@ -562,7 +562,7 @@ int zap_huge_pmd(struct mmu_gather *tlb,
 			pmd_clear(pmd);
 			page_remove_rmap(page);
 			VM_BUG_ON(page_mapcount(page) < 0);
-			add_mm_counter(tlb->mm, anon_rss, -HPAGE_PMD_NR);
+			add_mm_counter(tlb->mm, MM_ANONPAGES, -HPAGE_PMD_NR);
 			spin_unlock(&tlb->mm->page_table_lock);
 			VM_BUG_ON(!PageHead(page));
 			tlb_remove_page(tlb, page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
