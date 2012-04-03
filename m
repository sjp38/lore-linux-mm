Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 0AA4F6B0044
	for <linux-mm@kvack.org>; Mon,  2 Apr 2012 21:30:22 -0400 (EDT)
Received: by iajr24 with SMTP id r24so6557991iaj.14
        for <linux-mm@kvack.org>; Mon, 02 Apr 2012 18:30:22 -0700 (PDT)
Date: Mon, 2 Apr 2012 18:30:20 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 1/2] mm, thp: remove unnecessary ret variable
Message-ID: <alpine.DEB.2.00.1204021829260.25776@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org

The "ret" variable is unnecessary in __do_huge_pmd_anonymous_page(), so
remove it.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/huge_memory.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -636,7 +636,6 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 					unsigned long haddr, pmd_t *pmd,
 					struct page *page)
 {
-	int ret = 0;
 	pgtable_t pgtable;
 
 	VM_BUG_ON(!PageCompound(page));
@@ -675,7 +674,7 @@ static int __do_huge_pmd_anonymous_page(struct mm_struct *mm,
 		spin_unlock(&mm->page_table_lock);
 	}
 
-	return ret;
+	return 0;
 }
 
 static inline gfp_t alloc_hugepage_gfpmask(int defrag, gfp_t extra_gfp)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
