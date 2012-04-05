Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 981756B004A
	for <linux-mm@kvack.org>; Thu,  5 Apr 2012 12:32:55 -0400 (EDT)
MIME-version: 1.0
Content-transfer-encoding: 7BIT
Content-type: TEXT/PLAIN
Received: from euspt1 ([210.118.77.14]) by mailout4.w1.samsung.com
 (Sun Java(tm) System Messaging Server 6.3-8.04 (built Jul 29 2009; 32bit))
 with ESMTP id <0M20000RWLYX3S80@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 05 Apr 2012 17:32:57 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M20009RDLYTP5@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Thu, 05 Apr 2012 17:32:53 +0100 (BST)
Date: Thu, 05 Apr 2012 18:32:13 +0200
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: [PATCH 2/2] mm: compaction: allow isolation of lower order buddy pages
In-reply-to: <1333643534-1591-1-git-send-email-b.zolnierkie@samsung.com>
Message-id: <1333643534-1591-3-git-send-email-b.zolnierkie@samsung.com>
References: <1333643534-1591-1-git-send-email-b.zolnierkie@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: mgorman@suse.de, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>

Allow lower order buddy pages in suitable_migration_target()
so isolate_freepages() can isolate them as free pages during
compaction_alloc() phase.

Cc: Mel Gorman <mgorman@suse.de>
Signed-off-by: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 mm/compaction.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index bc77135..642c17a 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -115,8 +115,8 @@ static bool suitable_migration_target(struct page *page)
 	if (migratetype == MIGRATE_ISOLATE || migratetype == MIGRATE_RESERVE)
 		return false;
 
-	/* If the page is a large free page, then allow migration */
-	if (PageBuddy(page) && page_order(page) >= pageblock_order)
+	/* If the page is a free page, then allow migration */
+	if (PageBuddy(page))
 		return true;
 
 	/* If the block is MIGRATE_MOVABLE, allow migration */
-- 
1.7.9.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
