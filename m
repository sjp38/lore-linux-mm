Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id B462B6B0012
	for <linux-mm@kvack.org>; Mon, 30 May 2011 20:49:54 -0400 (EDT)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id p4V0nr0E024175
	for <linux-mm@kvack.org>; Mon, 30 May 2011 17:49:53 -0700
Received: from pzk35 (pzk35.prod.google.com [10.243.19.163])
	by kpbe13.cbf.corp.google.com with ESMTP id p4V0npWG012586
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 30 May 2011 17:49:52 -0700
Received: by pzk35 with SMTP id 35so1949265pzk.25
        for <linux-mm@kvack.org>; Mon, 30 May 2011 17:49:51 -0700 (PDT)
Date: Mon, 30 May 2011 17:49:51 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 10/14] mm: truncate functions are in truncate.c
In-Reply-To: <alpine.LSU.2.00.1105301726180.5482@sister.anvils>
Message-ID: <alpine.LSU.2.00.1105301748150.5482@sister.anvils>
References: <alpine.LSU.2.00.1105301726180.5482@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Correct comment on truncate_inode_pages*() in linux/mm.h; and remove
declaration of page_unuse(), it didn't exist even in 2.2.26 or 2.4.0!

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/mm.h |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

--- linux.orig/include/linux/mm.h	2011-05-30 13:56:10.444798255 -0700
+++ linux/include/linux/mm.h	2011-05-30 14:43:05.642758070 -0700
@@ -1445,8 +1445,7 @@ extern int do_munmap(struct mm_struct *,
 
 extern unsigned long do_brk(unsigned long, unsigned long);
 
-/* filemap.c */
-extern unsigned long page_unuse(struct page *);
+/* truncate.c */
 extern void truncate_inode_pages(struct address_space *, loff_t);
 extern void truncate_inode_pages_range(struct address_space *,
 				       loff_t lstart, loff_t lend);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
