Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 607DE6B0031
	for <linux-mm@kvack.org>; Thu,  1 Aug 2013 22:08:02 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 1/4] mm, page_alloc: add likely macro to help compiler optimization
Date: Fri,  2 Aug 2013 11:07:56 +0900
Message-Id: <1375409279-16919-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

We rarely allocate a page with ALLOC_NO_WATERMARKS and it is used
in slow path. For making fast path more faster, add likely macro to
help compiler optimization.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b100255..86ad44b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1901,7 +1901,7 @@ zonelist_scan:
 			goto this_zone_full;
 
 		BUILD_BUG_ON(ALLOC_NO_WATERMARKS < NR_WMARK);
-		if (!(alloc_flags & ALLOC_NO_WATERMARKS)) {
+		if (likely(!(alloc_flags & ALLOC_NO_WATERMARKS))) {
 			unsigned long mark;
 			int ret;
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
