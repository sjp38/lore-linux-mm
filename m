From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 10/24] HWPOISON: remove the free buddy page handler
Date: Wed, 02 Dec 2009 11:12:41 +0800
Message-ID: <20091202043044.878843398@intel.com>
References: <20091202031231.735876003@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 05D486007A3
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 23:37:37 -0500 (EST)
Content-Disposition: inline; filename=hwpoison-remove-free-handler.patch
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

The buddy page has already be handled in the very beginning.
So remove redundant code.

CC: Andi Kleen <andi@firstfloor.org>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/memory-failure.c |    9 ---------
 1 file changed, 9 deletions(-)

--- linux-mm.orig/mm/memory-failure.c	2009-11-09 10:57:50.000000000 +0800
+++ linux-mm/mm/memory-failure.c	2009-11-09 10:59:26.000000000 +0800
@@ -379,14 +379,6 @@ static int me_unknown(struct page *p, un
 }
 
 /*
- * Free memory
- */
-static int me_free(struct page *p, unsigned long pfn)
-{
-	return DELAYED;
-}
-
-/*
  * Clean (or cleaned) page cache page.
  */
 static int me_pagecache_clean(struct page *p, unsigned long pfn)
@@ -592,7 +584,6 @@ static struct page_state {
 	int (*action)(struct page *p, unsigned long pfn);
 } error_states[] = {
 	{ reserved,	reserved,	"reserved kernel",	me_ignore },
-	{ buddy,	buddy,		"free kernel",	me_free },
 
 	/*
 	 * Could in theory check if slab page is free or if we can drop


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
