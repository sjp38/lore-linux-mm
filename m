Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 821CD6B0149
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 04:57:42 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id kx10so1522146pab.5
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 01:57:42 -0700 (PDT)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id pc9si2752633pac.476.2014.04.03.01.57.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Thu, 03 Apr 2014 01:57:41 -0700 (PDT)
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0N3G002VR675Z670@mailout2.samsung.com> for linux-mm@kvack.org;
 Thu, 03 Apr 2014 17:57:05 +0900 (KST)
From: Heesub Shin <heesub.shin@samsung.com>
Subject: [PATCH 1/2] mm/compaction: clean up unused code lines
Date: Thu, 03 Apr 2014 17:57:03 +0900
Message-id: <1396515424-18794-1-git-send-email-heesub.shin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Heesub Shin <heesub.shin@samsung.com>, Dongjun Shin <d.j.shin@samsung.com>, Sunghwan Yun <sunghwan.yun@samsung.com>

This commit removes code lines currently not in use or never called.

Signed-off-by: Heesub Shin <heesub.shin@samsung.com>
Cc: Dongjun Shin <d.j.shin@samsung.com>
Cc: Sunghwan Yun <sunghwan.yun@samsung.com>
---
 mm/compaction.c | 10 ----------
 1 file changed, 10 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 9635083..1ef9144 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -208,12 +208,6 @@ static bool compact_checklock_irqsave(spinlock_t *lock, unsigned long *flags,
 	return true;
 }
 
-static inline bool compact_trylock_irqsave(spinlock_t *lock,
-			unsigned long *flags, struct compact_control *cc)
-{
-	return compact_checklock_irqsave(lock, flags, false, cc);
-}
-
 /* Returns true if the page is within a block suitable for migration to */
 static bool suitable_migration_target(struct page *page)
 {
@@ -728,7 +722,6 @@ static void isolate_freepages(struct zone *zone,
 			continue;
 
 		/* Found a block suitable for isolating free pages from */
-		isolated = 0;
 
 		/*
 		 * As pfn may not start aligned, pfn+pageblock_nr_page
@@ -1160,9 +1153,6 @@ static void __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
 			if (zone_watermark_ok(zone, cc->order,
 						low_wmark_pages(zone), 0, 0))
 				compaction_defer_reset(zone, cc->order, false);
-			/* Currently async compaction is never deferred. */
-			else if (cc->sync)
-				defer_compaction(zone, cc->order);
 		}
 
 		VM_BUG_ON(!list_empty(&cc->freepages));
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
