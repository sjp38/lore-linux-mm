Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D99C7600762
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 16:16:34 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
References: <200912081016.198135742@firstfloor.org>
In-Reply-To: <200912081016.198135742@firstfloor.org>
Subject: [PATCH] [4/31] HWPOISON: remove the anonymous entry
Message-Id: <20091208211620.4DAC1B151F@basil.firstfloor.org>
Date: Tue,  8 Dec 2009 22:16:20 +0100 (CET)
Sender: owner-linux-mm@kvack.org
To: fengguang.wu@intel.comfengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


From: Wu Fengguang <fengguang.wu@intel.com>

(PG_swapbacked && !PG_lru) pages should not happen.
Better to treat them as unknown pages.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
Signed-off-by: Andi Kleen <ak@linux.intel.com>

---
 mm/memory-failure.c |    1 -
 1 file changed, 1 deletion(-)

Index: linux/mm/memory-failure.c
===================================================================
--- linux.orig/mm/memory-failure.c
+++ linux/mm/memory-failure.c
@@ -611,7 +611,6 @@ static struct page_state {
 
 	{ lru|dirty,	lru|dirty,	"LRU",		me_pagecache_dirty },
 	{ lru|dirty,	lru,		"clean LRU",	me_pagecache_clean },
-	{ swapbacked,	swapbacked,	"anonymous",	me_pagecache_clean },
 
 	/*
 	 * Catchall entry: must be at end.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
