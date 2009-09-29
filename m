Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 017446B005A
	for <linux-mm@kvack.org>; Mon, 28 Sep 2009 22:12:33 -0400 (EDT)
Received: by ywh39 with SMTP id 39so5680712ywh.12
        for <linux-mm@kvack.org>; Mon, 28 Sep 2009 19:25:11 -0700 (PDT)
From: Huang Shijie <shijie8@gmail.com>
Subject: [PATCH] rmap : fix the comment
Date: Tue, 29 Sep 2009 10:25:06 +0800
Message-Id: <1254191106-20903-1-git-send-email-shijie8@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: hugh.dickins@tiscali.co.uk, linux-mm@kvack.org, Huang Shijie <shijie8@gmail.com>
List-ID: <linux-mm.kvack.org>

The page_address_in_vma() is not only used in unuse_vma().

Signed-off-by: Huang Shijie <shijie8@gmail.com>
---
 mm/rmap.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 28aafe2..dd43373 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -242,8 +242,8 @@ vma_address(struct page *page, struct vm_area_struct *vma)
 }
 
 /*
- * At what user virtual address is page expected in vma? checking that the
- * page matches the vma: currently only used on anon pages, by unuse_vma;
+ * At what user virtual address is page expected in vma?
+ * checking that the page matches the vma.
  */
 unsigned long page_address_in_vma(struct page *page, struct vm_area_struct *vma)
 {
-- 
1.6.0.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
