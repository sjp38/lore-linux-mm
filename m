Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 468C26B13F0
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 09:41:40 -0500 (EST)
Date: Wed, 1 Feb 2012 17:41:01 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] mm: compaction: make compact_control order signed
Message-ID: <20120201144101.GA5397@elgon.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org

"order" is -1 when compacting via /proc/sys/vm/compact_memory.  Making
it unsigned causes a bug in __compact_pgdat() when we test:

	if (cc->order < 0 || !compaction_deferred(zone, cc->order))
		compact_zone(zone, cc);

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/mm/compaction.c b/mm/compaction.c
index 382831e..5f80a11 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -35,7 +35,7 @@ struct compact_control {
 	unsigned long migrate_pfn;	/* isolate_migratepages search base */
 	bool sync;			/* Synchronous migration */
 
-	unsigned int order;		/* order a direct compactor needs */
+	int order;			/* order a direct compactor needs */
 	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
 	struct zone *zone;
 };

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
