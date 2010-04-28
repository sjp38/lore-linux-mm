Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E68716B01F3
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 12:17:15 -0400 (EDT)
Message-Id: <20100428161708.365052108@szeredi.hu>
References: <20100428161636.272097923@szeredi.hu>
Date: Wed, 28 Apr 2010 18:16:38 +0200
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [RFC PATCH 2/6] mm: export remove_from_page_cache() to modules
Content-Disposition: inline; filename=export-remove_from_page_cache.patch
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: jens.axboe@oracle.com, akpm@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

This is needed to enable moving pages into the page cache in fuse with
splice(..., SPLICE_F_MOVE).

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---
 mm/filemap.c |    1 +
 1 file changed, 1 insertion(+)

Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c	2010-04-26 11:33:57.000000000 +0200
+++ linux-2.6/mm/filemap.c	2010-04-28 15:50:30.000000000 +0200
@@ -151,6 +151,7 @@ void remove_from_page_cache(struct page
 	spin_unlock_irq(&mapping->tree_lock);
 	mem_cgroup_uncharge_cache_page(page);
 }
+EXPORT_SYMBOL(remove_from_page_cache);
 
 static int sync_page(void *word)
 {

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
