Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E3F866B01FE
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 17:01:45 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 08/14] mm: Move definition for LRU isolation modes to a header
Date: Tue, 20 Apr 2010 22:01:10 +0100
Message-Id: <1271797276-31358-9-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1271797276-31358-1-git-send-email-mel@csn.ul.ie>
References: <1271797276-31358-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Currently, vmscan.c defines the isolation modes for __isolate_lru_page().
Memory compaction needs access to these modes for isolating pages for
migration.  This patch exports them.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Christoph Lameter <cl@linux-foundation.org>
---
 include/linux/swap.h |    5 +++++
 mm/vmscan.c          |    5 -----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 94ec325..32af03c 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -238,6 +238,11 @@ static inline void lru_cache_add_active_file(struct page *page)
 	__lru_cache_add(page, LRU_ACTIVE_FILE);
 }
 
+/* LRU Isolation modes. */
+#define ISOLATE_INACTIVE 0	/* Isolate inactive pages. */
+#define ISOLATE_ACTIVE 1	/* Isolate active pages. */
+#define ISOLATE_BOTH 2		/* Isolate both active and inactive pages. */
+
 /* linux/mm/vmscan.c */
 extern unsigned long try_to_free_pages(struct zonelist *zonelist, int order,
 					gfp_t gfp_mask, nodemask_t *mask);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 1070f83..8bdd85c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -839,11 +839,6 @@ keep:
 	return nr_reclaimed;
 }
 
-/* LRU Isolation modes. */
-#define ISOLATE_INACTIVE 0	/* Isolate inactive pages. */
-#define ISOLATE_ACTIVE 1	/* Isolate active pages. */
-#define ISOLATE_BOTH 2		/* Isolate both active and inactive pages. */
-
 /*
  * Attempt to remove the specified page from its LRU.  Only take this page
  * if it is of the appropriate PageActive status.  Pages which are being
-- 
1.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
