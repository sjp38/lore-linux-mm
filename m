Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id BD7E06B0082
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 13:51:34 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 14/27] Inline buffered_rmqueue()
Date: Mon, 16 Mar 2009 17:53:28 +0000
Message-Id: <1237226020-14057-15-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1237226020-14057-1-git-send-email-mel@csn.ul.ie>
References: <1237226020-14057-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

buffered_rmqueue() is in the fast path so inline it. Because it only has
one call site, this actually should reduce text bloat instead of
increase it.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/page_alloc.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a3ca80d..9f7631e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1079,7 +1079,8 @@ void split_page(struct page *page, unsigned int order)
  * we cheat by calling it from here, in the order > 0 path.  Saves a branch
  * or two.
  */
-static struct page *buffered_rmqueue(struct zone *preferred_zone,
+static inline
+struct page *buffered_rmqueue(struct zone *preferred_zone,
 			struct zone *zone, int order, gfp_t gfp_flags,
 			int migratetype, int cold)
 {
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
