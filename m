Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 143F16B005A
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 15:09:29 -0400 (EDT)
From: Vincent Li <macli@brc.ubc.ca>
Subject: [PATCH] mm/memory-failure: remove CONFIG_UNEVICTABLE_LRU config option
Date: Fri, 28 Aug 2009 12:09:13 -0700
Message-Id: <1251486553-23181-1-git-send-email-macli@brc.ubc.ca>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <ak@suse.de>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Vincent Li <macli@brc.ubc.ca>
List-ID: <linux-mm.kvack.org>

Commit 683776596 (remove CONFIG_UNEVICTABLE_LRU config option) removed this config option.
Removed it from mm/memory-failure too.

Signed-off-by: Vincent Li <macli@brc.ubc.ca>
---
 mm/memory-failure.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index f78d9fc..2bc4c50 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -587,10 +587,8 @@ static struct page_state {
 	{ sc|dirty,	sc|dirty,	"swapcache",	me_swapcache_dirty },
 	{ sc|dirty,	sc,		"swapcache",	me_swapcache_clean },
 
-#ifdef CONFIG_UNEVICTABLE_LRU
 	{ unevict|dirty, unevict|dirty,	"unevictable LRU", me_pagecache_dirty},
 	{ unevict,	unevict,	"unevictable LRU", me_pagecache_clean},
-#endif
 
 #ifdef CONFIG_HAVE_MLOCKED_PAGE_BIT
 	{ mlock|dirty,	mlock|dirty,	"mlocked LRU",	me_pagecache_dirty },
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
