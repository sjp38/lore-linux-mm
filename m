Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 3EECF6B0031
	for <linux-mm@kvack.org>; Thu,  5 Sep 2013 05:10:22 -0400 (EDT)
Message-ID: <52284A5E.7000306@huawei.com>
Date: Thu, 5 Sep 2013 17:09:50 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mm: use populated_zone() instead of if(zone->present_pages)
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Liujiang <jiang.liu@huawei.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Xishi Qiu <qiuxishi@huawei.com>

Use "if (zone->present_pages)" instead of "if (zone->present_pages)".
Simplify the code, no functional change.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/page_alloc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b100255..30ef67c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4195,7 +4195,7 @@ static __meminit void zone_pcp_init(struct zone *zone)
 	 */
 	zone->pageset = &boot_pageset;
 
-	if (zone->present_pages)
+	if (populated_zone(zone))
 		printk(KERN_DEBUG "  %s zone: %lu pages, LIFO batch:%u\n",
 			zone->name, zone->present_pages,
 					 zone_batchsize(zone));
@@ -5087,7 +5087,7 @@ static void check_for_memory(pg_data_t *pgdat, int nid)
 
 	for (zone_type = 0; zone_type <= ZONE_MOVABLE - 1; zone_type++) {
 		struct zone *zone = &pgdat->node_zones[zone_type];
-		if (zone->present_pages) {
+		if (populated_zone(zone)) {
 			node_set_state(nid, N_HIGH_MEMORY);
 			if (N_NORMAL_MEMORY != N_HIGH_MEMORY &&
 			    zone_type <= ZONE_NORMAL)
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
