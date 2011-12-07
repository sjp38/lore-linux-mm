Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 5378C6B005C
	for <linux-mm@kvack.org>; Wed,  7 Dec 2011 12:02:48 -0500 (EST)
Received: by eekc41 with SMTP id c41so852075eek.14
        for <linux-mm@kvack.org>; Wed, 07 Dec 2011 09:02:46 -0800 (PST)
From: Tom Gundersen <teg@jklm.no>
Subject: [PATCH] mm: mark some messages as INFO
Date: Wed,  7 Dec 2011 18:02:40 +0100
Message-Id: <1323277360-3155-1-git-send-email-teg@jklm.no>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Tom Gundersen <teg@jklm.no>

This reduces the noise in

$ dmesg --kernel --level=err,warn

Signed-off-by: Tom Gundersen <teg@jklm.no>
---
 mm/page_alloc.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9dd443d..e427e99 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3270,14 +3270,14 @@ void __ref build_all_zonelists(void *data)
 	else
 		page_group_by_mobility_disabled = 0;
 
-	printk("Built %i zonelists in %s order, mobility grouping %s.  "
+	printk(KERN_INFO "Built %i zonelists in %s order, mobility grouping %s.  "
 		"Total pages: %ld\n",
 			nr_online_nodes,
 			zonelist_order_name[current_zonelist_order],
 			page_group_by_mobility_disabled ? "off" : "on",
 			vm_total_pages);
 #ifdef CONFIG_NUMA
-	printk("Policy zone: %s\n", zone_names[policy_zone]);
+	printk(KERN_INFO "Policy zone: %s\n", zone_names[policy_zone]);
 #endif
 }
 
@@ -4913,31 +4913,31 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
 	find_zone_movable_pfns_for_nodes(zone_movable_pfn);
 
 	/* Print out the zone ranges */
-	printk("Zone PFN ranges:\n");
+	printk(KERN_INFO "Zone PFN ranges:\n");
 	for (i = 0; i < MAX_NR_ZONES; i++) {
 		if (i == ZONE_MOVABLE)
 			continue;
-		printk("  %-8s ", zone_names[i]);
+		printk(KERN_INFO "  %-8s ", zone_names[i]);
 		if (arch_zone_lowest_possible_pfn[i] ==
 				arch_zone_highest_possible_pfn[i])
-			printk("empty\n");
+			printk(KERN_INFO "empty\n");
 		else
-			printk("%0#10lx -> %0#10lx\n",
+			printk(KERN_INFO "%0#10lx -> %0#10lx\n",
 				arch_zone_lowest_possible_pfn[i],
 				arch_zone_highest_possible_pfn[i]);
 	}
 
 	/* Print out the PFNs ZONE_MOVABLE begins at in each node */
-	printk("Movable zone start PFN for each node\n");
+	printk(KERN_INFO "Movable zone start PFN for each node\n");
 	for (i = 0; i < MAX_NUMNODES; i++) {
 		if (zone_movable_pfn[i])
-			printk("  Node %d: %lu\n", i, zone_movable_pfn[i]);
+			printk(KERN_INFO "  Node %d: %lu\n", i, zone_movable_pfn[i]);
 	}
 
 	/* Print out the early_node_map[] */
-	printk("early_node_map[%d] active PFN ranges\n", nr_nodemap_entries);
+	printk(KERN_INFO "early_node_map[%d] active PFN ranges\n", nr_nodemap_entries);
 	for (i = 0; i < nr_nodemap_entries; i++)
-		printk("  %3d: %0#10lx -> %0#10lx\n", early_node_map[i].nid,
+		printk(KERN_INFO "  %3d: %0#10lx -> %0#10lx\n", early_node_map[i].nid,
 						early_node_map[i].start_pfn,
 						early_node_map[i].end_pfn);
 
-- 
1.7.8

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
