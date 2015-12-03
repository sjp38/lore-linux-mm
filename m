Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 2521A6B0257
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 02:11:42 -0500 (EST)
Received: by pacej9 with SMTP id ej9so63226704pac.2
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 23:11:41 -0800 (PST)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id z75si10160829pfa.74.2015.12.02.23.11.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 23:11:41 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so63038779pac.3
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 23:11:41 -0800 (PST)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH v3 2/7] mm/compaction: remove unused defer_compaction() in compaction.h
Date: Thu,  3 Dec 2015 16:11:16 +0900
Message-Id: <1449126681-19647-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1449126681-19647-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1449126681-19647-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

It's not used externally. Remove it in compaction.h.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/compaction.h | 1 -
 mm/compaction.c            | 2 +-
 2 files changed, 1 insertion(+), 2 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 4cd4ddf..359b07a 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -46,7 +46,6 @@ extern void reset_isolation_suitable(pg_data_t *pgdat);
 extern unsigned long compaction_suitable(struct zone *zone, int order,
 					int alloc_flags, int classzone_idx);
 
-extern void defer_compaction(struct zone *zone, int order);
 extern bool compaction_deferred(struct zone *zone, int order);
 extern void compaction_defer_reset(struct zone *zone, int order,
 				bool alloc_success);
diff --git a/mm/compaction.c b/mm/compaction.c
index 564047c..f144494 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -124,7 +124,7 @@ static struct page *pageblock_pfn_to_page(unsigned long start_pfn,
  * allocation success. 1 << compact_defer_limit compactions are skipped up
  * to a limit of 1 << COMPACT_MAX_DEFER_SHIFT
  */
-void defer_compaction(struct zone *zone, int order)
+static void defer_compaction(struct zone *zone, int order)
 {
 	zone->compact_considered = 0;
 	zone->compact_defer_shift++;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
