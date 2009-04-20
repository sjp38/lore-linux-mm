Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D752B5F0013
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 18:20:10 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 15/25] Inline __rmqueue_fallback()
Date: Mon, 20 Apr 2009 23:20:01 +0100
Message-Id: <1240266011-11140-16-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1240266011-11140-1-git-send-email-mel@csn.ul.ie>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

__rmqueue_fallback() is in the slow path but has only one call site. It
actually reduces text if it's inlined.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/page_alloc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2dfe3aa..83da463 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -775,8 +775,8 @@ static int move_freepages_block(struct zone *zone, struct page *page,
 }
 
 /* Remove an element from the buddy allocator from the fallback list */
-static struct page *__rmqueue_fallback(struct zone *zone, int order,
-						int start_migratetype)
+static inline struct page *
+__rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 {
 	struct free_area * area;
 	int current_order;
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
