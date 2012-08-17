Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id A077E6B0073
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 10:14:41 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 5/7] mm: compaction: Update comment in try_to_compact_pages
Date: Fri, 17 Aug 2012 15:14:31 +0100
Message-Id: <1345212873-22447-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1345212873-22447-1-git-send-email-mgorman@suse.de>
References: <1345212873-22447-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Jim Schutt <jaschut@sandia.gov>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

The comment about order applied when the check was
order > PAGE_ALLOC_COSTLY_ORDER which has not been the case since
[c5a73c3d: thp: use compaction for all allocation orders]. Fixing
the comment while I'm in the general area.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Rik van Riel <riel@redhat.com>
Reviewed-by: Minchan Kim <minchan@kernel.org>
---
 mm/compaction.c |    6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 6bf7f86..1c51395 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -871,11 +871,7 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 	struct zone *zone;
 	int rc = COMPACT_SKIPPED;
 
-	/*
-	 * Check whether it is worth even starting compaction. The order check is
-	 * made because an assumption is made that the page allocator can satisfy
-	 * the "cheaper" orders without taking special steps
-	 */
+	/* Check if the GFP flags allow compaction */
 	if (!order || !may_enter_fs || !may_perform_io)
 		return rc;
 
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
