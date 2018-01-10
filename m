Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D188E6B0069
	for <linux-mm@kvack.org>; Wed, 10 Jan 2018 03:43:56 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id n13so7315097wmc.3
        for <linux-mm@kvack.org>; Wed, 10 Jan 2018 00:43:56 -0800 (PST)
Received: from techadventures.net (techadventures.net. [62.201.165.239])
        by mx.google.com with ESMTP id y5si3366822wrd.488.2018.01.10.00.43.55
        for <linux-mm@kvack.org>;
        Wed, 10 Jan 2018 00:43:55 -0800 (PST)
Date: Wed, 10 Jan 2018 09:43:55 +0100
From: Oscar Salvador <osalvador@techadventures.net>
Subject: [PATCH v2] mm/page_owner: Clean up init_pages_in_zone()
Message-ID: <20180110084355.GA22822@techadventures.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: vbabka@suse.cz, mhocko@suse.com, akpm@linux-foundation.org

This patch removes two redundant assignments in init_pages_in_zone function.

Signed-off-by: Oscar Salvador <osalvador@techadventures.net>
---
 mm/page_owner.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/mm/page_owner.c b/mm/page_owner.c
index 69f83fc763bb..b361781e5ab6 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -528,14 +528,11 @@ read_page_owner(struct file *file, char __user *buf, size_t count, loff_t *ppos)
 
 static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
 {
-	struct page *page;
-	struct page_ext *page_ext;
 	unsigned long pfn = zone->zone_start_pfn, block_end_pfn;
 	unsigned long end_pfn = pfn + zone->spanned_pages;
 	unsigned long count = 0;
 
 	/* Scan block by block. First and last block may be incomplete */
-	pfn = zone->zone_start_pfn;
 
 	/*
 	 * Walk the zone in pageblock_nr_pages steps. If a page block spans
@@ -551,9 +548,9 @@ static void init_pages_in_zone(pg_data_t *pgdat, struct zone *zone)
 		block_end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
 		block_end_pfn = min(block_end_pfn, end_pfn);
 
-		page = pfn_to_page(pfn);
-
 		for (; pfn < block_end_pfn; pfn++) {
+			struct page *page;
+			struct page_ext *page_ext;
 			if (!pfn_valid_within(pfn))
 				continue;
 
-- 
2.13.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
