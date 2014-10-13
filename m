Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 334BB6B0069
	for <linux-mm@kvack.org>; Mon, 13 Oct 2014 07:30:26 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id ft15so5486566pdb.17
        for <linux-mm@kvack.org>; Mon, 13 Oct 2014 04:30:25 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id rm10si10184878pab.97.2014.10.13.04.30.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Oct 2014 04:30:25 -0700 (PDT)
Date: Mon, 13 Oct 2014 22:30:21 +1100
From: Anton Blanchard <anton@samba.org>
Subject: [PATCH] mm: page_alloc: Convert boot printks without log level to
 pr_info
Message-ID: <20141013223021.431284a7@kryten>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, rientjes@google.com, hannes@cmpxchg.org, riel@redhat.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org


Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3894,14 +3894,14 @@ void __ref build_all_zonelists(pg_data_t
 	else
 		page_group_by_mobility_disabled = 0;
 
-	printk("Built %i zonelists in %s order, mobility grouping %s.  "
+	pr_info("Built %i zonelists in %s order, mobility grouping %s.  "
 		"Total pages: %ld\n",
 			nr_online_nodes,
 			zonelist_order_name[current_zonelist_order],
 			page_group_by_mobility_disabled ? "off" : "on",
 			vm_total_pages);
 #ifdef CONFIG_NUMA
-	printk("Policy zone: %s\n", zone_names[policy_zone]);
+	pr_info("Policy zone: %s\n", zone_names[policy_zone]);
 #endif
 }
 
@@ -5333,33 +5333,33 @@ void __init free_area_init_nodes(unsigne
 	find_zone_movable_pfns_for_nodes();
 
 	/* Print out the zone ranges */
-	printk("Zone ranges:\n");
+	pr_info("Zone ranges:\n");
 	for (i = 0; i < MAX_NR_ZONES; i++) {
 		if (i == ZONE_MOVABLE)
 			continue;
-		printk(KERN_CONT "  %-8s ", zone_names[i]);
+		pr_info("  %-8s ", zone_names[i]);
 		if (arch_zone_lowest_possible_pfn[i] ==
 				arch_zone_highest_possible_pfn[i])
-			printk(KERN_CONT "empty\n");
+			pr_cont("empty\n");
 		else
-			printk(KERN_CONT "[mem %0#10lx-%0#10lx]\n",
+			pr_cont("[mem %0#10lx-%0#10lx]\n",
 				arch_zone_lowest_possible_pfn[i] << PAGE_SHIFT,
 				(arch_zone_highest_possible_pfn[i]
 					<< PAGE_SHIFT) - 1);
 	}
 
 	/* Print out the PFNs ZONE_MOVABLE begins at in each node */
-	printk("Movable zone start for each node\n");
+	pr_info("Movable zone start for each node\n");
 	for (i = 0; i < MAX_NUMNODES; i++) {
 		if (zone_movable_pfn[i])
-			printk("  Node %d: %#010lx\n", i,
+			pr_info("  Node %d: %#010lx\n", i,
 			       zone_movable_pfn[i] << PAGE_SHIFT);
 	}
 
 	/* Print out the early node map */
-	printk("Early memory node ranges\n");
+	pr_info("Early memory node ranges\n");
 	for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, &nid)
-		printk("  node %3d: [mem %#010lx-%#010lx]\n", nid,
+		pr_info("  node %3d: [mem %#010lx-%#010lx]\n", nid,
 		       start_pfn << PAGE_SHIFT, (end_pfn << PAGE_SHIFT) - 1);
 
 	/* Initialise every node */
@@ -5495,7 +5495,7 @@ void __init mem_init_print_info(const ch
 
 #undef	adj_init_size
 
-	printk("Memory: %luK/%luK available "
+	pr_info("Memory: %luK/%luK available "
 	       "(%luK kernel code, %luK rwdata, %luK rodata, "
 	       "%luK init, %luK bss, %luK reserved"
 #ifdef	CONFIG_HIGHMEM

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
