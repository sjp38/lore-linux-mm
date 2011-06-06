Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D68F86B012E
	for <linux-mm@kvack.org>; Mon,  6 Jun 2011 00:37:01 -0400 (EDT)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id p564awNC020196
	for <linux-mm@kvack.org>; Sun, 5 Jun 2011 21:36:58 -0700
Received: from pxj1 (pxj1.prod.google.com [10.243.27.65])
	by kpbe12.cbf.corp.google.com with ESMTP id p564au7M013990
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 5 Jun 2011 21:36:56 -0700
Received: by pxj1 with SMTP id 1so1352505pxj.37
        for <linux-mm@kvack.org>; Sun, 05 Jun 2011 21:36:56 -0700 (PDT)
Date: Sun, 5 Jun 2011 21:36:59 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 10/14] mm: truncate functions are in truncate.c
In-Reply-To: <alpine.LSU.2.00.1106052116350.17116@sister.anvils>
Message-ID: <alpine.LSU.2.00.1106052135550.17116@sister.anvils>
References: <alpine.LSU.2.00.1106052116350.17116@sister.anvils>
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

--- linux.orig/include/linux/mm.h	2011-06-05 17:16:33.313740660 -0700
+++ linux/include/linux/mm.h	2011-06-05 18:57:56.399905055 -0700
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
