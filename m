Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C02B26B01F3
	for <linux-mm@kvack.org>; Tue, 13 Apr 2010 11:29:17 -0400 (EDT)
Received: by bwz23 with SMTP id 23so3243033bwz.6
        for <linux-mm@kvack.org>; Tue, 13 Apr 2010 08:29:15 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH 6/6] Add comment in alloc_pages_exact_node
Date: Wed, 14 Apr 2010 00:25:03 +0900
Message-Id: <d74305233536342dfeb1ca7ffe9e83495ce1f285.1271171877.git.minchan.kim@gmail.com>
In-Reply-To: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>
In-Reply-To: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>
References: <9918f566ab0259356cded31fd1dd80da6cae0c2b.1271171877.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <lliubbo@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

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
 include/linux/gfp.h |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index b65f003..7539c17 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -288,6 +288,11 @@ static inline struct page *alloc_pages_node(int nid, gfp_t gfp_mask,
 	return __alloc_pages(gfp_mask, order, node_zonelist(nid, gfp_mask));
 }
 
+/*
+ * NOTE : Allow page from fallback if page allocator can't find free page
+ * in your nid. Only if you want to allocate page from your nid, use
+ * __GFP_THISNODE flags with gfp_mask.
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
