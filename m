Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 98E756B004D
	for <linux-mm@kvack.org>; Sun,  4 Oct 2009 12:00:56 -0400 (EDT)
Received: by pzk17 with SMTP id 17so2225118pzk.1
        for <linux-mm@kvack.org>; Sun, 04 Oct 2009 09:00:55 -0700 (PDT)
From: Huang Shijie <shijie8@gmail.com>
Subject: [PATCH] rmap : fix the comment for try_to_unmap_anon
Date: Mon,  5 Oct 2009 00:00:50 +0800
Message-Id: <1254672050-3293-1-git-send-email-shijie8@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: hugh.dickins@tiscali.co.uk, linux-mm@kvack.org, Huang Shijie <shijie8@gmail.com>
List-ID: <linux-mm.kvack.org>

fix the comment for the try_to_unmap_anon with the new arguments.

Signed-off-by: Huang Shijie <shijie8@gmail.com>
---
 mm/rmap.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index dd43373..c8cf043 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -997,8 +997,7 @@ static int try_to_mlock_page(struct page *page, struct vm_area_struct *vma)
  * try_to_unmap_anon - unmap or unlock anonymous page using the object-based
  * rmap method
  * @page: the page to unmap/unlock
- * @unlock:  request for unlock rather than unmap [unlikely]
- * @migration:  unmapping for migration - ignored if @unlock
+ * @flags: action and flags
  *
  * Find all the mappings of a page using the mapping pointer and the vma chains
  * contained in the anon_vma struct it points to.
-- 
1.6.2.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
