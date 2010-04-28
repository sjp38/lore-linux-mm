Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 490966B01F6
	for <linux-mm@kvack.org>; Wed, 28 Apr 2010 12:17:31 -0400 (EDT)
Message-Id: <20100428161705.995898265@szeredi.hu>
References: <20100428161636.272097923@szeredi.hu>
Date: Wed, 28 Apr 2010 18:16:37 +0200
From: Miklos Szeredi <miklos@szeredi.hu>
Subject: [RFC PATCH 1/6] mm: export lru_cache_add_*() to modules
Content-Disposition: inline; filename=export-lru_cache_add.patch
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: jens.axboe@oracle.com, akpm@linux-foundation.org, torvalds@linux-foundation.org
List-ID: <linux-mm.kvack.org>

This is needed to enable moving pages into the page cache in fuse with
splice(..., SPLICE_F_MOVE).

Signed-off-by: Miklos Szeredi <mszeredi@suse.cz>
---
 mm/swap.c |    1 +
 1 file changed, 1 insertion(+)

Index: linux-2.6/mm/swap.c
===================================================================
--- linux-2.6.orig/mm/swap.c	2010-04-26 11:33:57.000000000 +0200
+++ linux-2.6/mm/swap.c	2010-04-28 15:50:28.000000000 +0200
@@ -224,6 +224,7 @@ void __lru_cache_add(struct page *page,
 		____pagevec_lru_add(pvec, lru);
 	put_cpu_var(lru_add_pvecs);
 }
+EXPORT_SYMBOL(__lru_cache_add);
 
 /**
  * lru_cache_add_lru - add a page to a page list

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
