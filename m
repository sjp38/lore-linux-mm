Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 7C4EE6B0081
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 05:10:51 -0400 (EDT)
Message-ID: <52020EF1.2060003@huawei.com>
Date: Wed, 7 Aug 2013 17:10:09 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 3/3] mm: use zone_is_initialized() instead of if(zone->wait_table)
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Xishi Qiu <qiuxishi@huawei.com>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Use "zone_is_initialized()" instead of "if (zone->wait_table)".
Simplify the code, no functional change.

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/memory_hotplug.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index f3fcac1..387654b 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -194,7 +194,7 @@ void register_page_bootmem_info_node(struct pglist_data *pgdat)
 
 	zone = &pgdat->node_zones[0];
 	for (; zone < pgdat->node_zones + MAX_NR_ZONES - 1; zone++) {
-		if (zone->wait_table) {
+		if (zone_is_initialized(zone)) {
 			nr_pages = zone->wait_table_hash_nr_entries
 				* sizeof(wait_queue_head_t);
 			nr_pages = PAGE_ALIGN(nr_pages) >> PAGE_SHIFT;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
