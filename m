From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 03/24] HWPOISON: remove the anonymous entry
Date: Wed, 02 Dec 2009 11:12:34 +0800
Message-ID: <20091202043043.959761646@intel.com>
References: <20091202031231.735876003@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8E5476B006A
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 23:37:36 -0500 (EST)
Content-Disposition: inline; filename=hwpoison-remove-anon-entry.patch
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-Id: linux-mm.kvack.org

(PG_swapbacked && !PG_lru) pages are rediculous.
Better to treat them as unknown pages.

CC: Andi Kleen <andi@firstfloor.org>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/memory-failure.c |    1 -
 1 file changed, 1 deletion(-)

--- linux-mm.orig/mm/memory-failure.c	2009-11-02 10:18:45.000000000 +0800
+++ linux-mm/mm/memory-failure.c	2009-11-02 10:26:17.000000000 +0800
@@ -589,7 +589,6 @@ static struct page_state {
 
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
