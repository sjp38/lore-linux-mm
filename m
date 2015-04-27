Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 1A1C16B0038
	for <linux-mm@kvack.org>; Mon, 27 Apr 2015 03:16:38 -0400 (EDT)
Received: by iedfl3 with SMTP id fl3so136081191ied.1
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 00:16:37 -0700 (PDT)
Received: from mail-ig0-x22b.google.com (mail-ig0-x22b.google.com. [2607:f8b0:4001:c05::22b])
        by mx.google.com with ESMTPS id m3si15119961iod.50.2015.04.27.00.16.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Apr 2015 00:16:37 -0700 (PDT)
Received: by igblo3 with SMTP id lo3so55085198igb.1
        for <linux-mm@kvack.org>; Mon, 27 Apr 2015 00:16:37 -0700 (PDT)
From: Derek Robson <robsonde@gmail.com>
Subject: [PATCH] mm: fixed Missing a blank line after declarations
Date: Mon, 27 Apr 2015 19:16:40 +1200
Message-Id: <1430119000-7196-1-git-send-email-robsonde@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Derek Robson <robsonde@gmail.com>

This patch fixes warnings found with checkpatch.pl error in compaction.c
WARNING: Missing a blank line after declarations

This patch adds blank lines to meet the preferred style.

Signed-off-by: Derek Robson <robsonde@gmail.com>
---
 mm/compaction.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/compaction.c b/mm/compaction.c
index 018f08d..6d564e0 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -57,6 +57,7 @@ static unsigned long release_freepages(struct list_head *freelist)
 
 	list_for_each_entry_safe(page, next, freelist, lru) {
 		unsigned long pfn = page_to_pfn(page);
+
 		list_del(&page->lru);
 		__free_page(page);
 		if (pfn > high_pfn)
@@ -246,6 +247,7 @@ void reset_isolation_suitable(pg_data_t *pgdat)
 
 	for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
 		struct zone *zone = &pgdat->node_zones[zoneid];
+
 		if (!populated_zone(zone))
 			continue;
 
-- 
2.3.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
