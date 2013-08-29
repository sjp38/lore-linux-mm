Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id F143F6B0033
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 19:32:17 -0400 (EDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH] ksm: Remove redundant __GFP_ZERO from kcalloc
Date: Thu, 29 Aug 2013 16:32:14 -0700
Message-Id: <1c47ec33fcbbf393f8d6decc9b3d6e18ed8b09a1.1377819069.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

kcalloc returns zeroed memory.
There's no need to use this flag.

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/ksm.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 0bea2b2..175fff7 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -2309,8 +2309,8 @@ static ssize_t merge_across_nodes_store(struct kobject *kobj,
 			 * Allocate stable and unstable together:
 			 * MAXSMP NODES_SHIFT 10 will use 16kB.
 			 */
-			buf = kcalloc(nr_node_ids + nr_node_ids,
-				sizeof(*buf), GFP_KERNEL | __GFP_ZERO);
+			buf = kcalloc(nr_node_ids + nr_node_ids, sizeof(*buf),
+				      GFP_KERNEL);
 			/* Let us assume that RB_ROOT is NULL is zero */
 			if (!buf)
 				err = -ENOMEM;
-- 
1.8.1.2.459.gbcd45b4.dirty

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
