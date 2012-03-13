Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 258DB6B004A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 11:34:12 -0400 (EDT)
Received: by dakn40 with SMTP id n40so1097761dak.9
        for <linux-mm@kvack.org>; Tue, 13 Mar 2012 08:34:11 -0700 (PDT)
From: Kautuk Consul <consul.kautuk@gmail.com>
Subject: [PATCH 2/2] page_alloc: Remove argument to find_zone_movable_pfns_for_nodes
Date: Tue, 13 Mar 2012 11:33:23 -0400
Message-Id: <1331652803-3092-1-git-send-email-consul.kautuk@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tejun Heo <tj@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kautuk Consul <consul.kautuk@gmail.com>

The find_zone_movable_pfns_for_nodes() function does not utiilize
the argument to it.

Removing this argument from the function prototype as well as its
caller, i.e. free_area_init_nodes().

Signed-off-by: Kautuk Consul <consul.kautuk@gmail.com>
---
 mm/page_alloc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3171f4c..a368b9b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4509,7 +4509,7 @@ static unsigned long __init early_calculate_totalpages(void)
  * memory. When they don't, some nodes will have more kernelcore than
  * others
  */
-static void __init find_zone_movable_pfns_for_nodes(unsigned long *movable_pfn)
+static void __init find_zone_movable_pfns_for_nodes(void)
 {
 	int i, nid;
 	unsigned long usable_startpfn;
@@ -4701,7 +4701,7 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
 
 	/* Find the PFNs that ZONE_MOVABLE begins at in each node */
 	memset(zone_movable_pfn, 0, sizeof(zone_movable_pfn));
-	find_zone_movable_pfns_for_nodes(zone_movable_pfn);
+	find_zone_movable_pfns_for_nodes();
 
 	/* Print out the zone ranges */
 	printk("Zone PFN ranges:\n");
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
