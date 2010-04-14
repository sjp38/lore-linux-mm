Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D1F546B01F5
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 11:00:51 -0400 (EDT)
Received: by mail-ww0-f41.google.com with SMTP id 26so145811wwf.14
        for <linux-mm@kvack.org>; Wed, 14 Apr 2010 08:00:49 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v2] Add comment in alloc_pages_exact_node
Date: Wed, 14 Apr 2010 23:58:39 +0900
Message-Id: <1271257119-30117-6-git-send-email-minchan.kim@gmail.com>
In-Reply-To: <1271257119-30117-1-git-send-email-minchan.kim@gmail.com>
References: <1271257119-30117-1-git-send-email-minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

V2
 o modify comment by suggestion. (Thanks to Mel)

alloc_pages_exact_node naming makes some people misleading.
They considered it following as.
"This function will allocate pages from node which I wanted
exactly".
But it can allocate pages from fallback list if page allocator
can't find free page from node user wanted.

So let's comment this NOTE.

Actually I wanted to change naming with better.
ex) alloc_pages_explict_node.
But I changed my mind since the comment would be enough.

If anybody suggests better name, I will do with pleasure.

Cc: Mel Gorman <mel@csn.ul.ie>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Bob Liu <lliubbo@gmail.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 include/linux/gfp.h |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index b65f003..56b5fe6 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -288,6 +288,12 @@ static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
 	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
 }
 
+/*
+ * Use this instead of alloc_pages_node when the caller knows
+ * exactly which node they need (as opposed to passing in -1
+ * for current). Fallback to other nodes will still occur
+ * unless __GFP_THISNODE is specified.
+ */
 static inline struct page *alloc_pages_exact_node(int nid, gfp_t gfp_mask,
 						unsigned int order)
 {
-- 
1.7.0.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
