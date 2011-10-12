Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 320616B002E
	for <linux-mm@kvack.org>; Wed, 12 Oct 2011 10:39:39 -0400 (EDT)
Received: by wwi36 with SMTP id 36so108314wwi.26
        for <linux-mm@kvack.org>; Wed, 12 Oct 2011 07:39:36 -0700 (PDT)
MIME-Version: 1.0
Date: Wed, 12 Oct 2011 22:39:36 +0800
Message-ID: <CAJd=RBBuwmcV8srUyPGnKUp=RPKvsSd+4BbLrh--aHFGC5s7+g@mail.gmail.com>
Subject: [PATCH] mm/huge_memory: Clean up typo when copying user highpage
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

Hi Andrea

When copying user highpage, the PAGE_SHIFT in the third parameter is a typo,
I think, and is replaced with PAGE_SIZE.

When configuring transparent hugepage, it depends on x86 and MMU.
Would you please tippoint why other archs with MMU, say MIPS, are masked out?

Thanks

Signed-off-by: Hillf Danton <dhillf@gmail.com>
---

--- a/mm/huge_memory.c	Sat Aug 13 11:45:14 2011
+++ b/mm/huge_memory.c	Wed Oct 12 22:26:15 2011
@@ -829,7 +829,7 @@ static int do_huge_pmd_wp_page_fallback(

 	for (i = 0; i < HPAGE_PMD_NR; i++) {
 		copy_user_highpage(pages[i], page + i,
-				   haddr + PAGE_SHIFT*i, vma);
+				   haddr + PAGE_SIZE * i, vma);
 		__SetPageUptodate(pages[i]);
 		cond_resched();
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
