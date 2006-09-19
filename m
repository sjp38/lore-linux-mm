Date: Mon, 18 Sep 2006 19:50:06 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: zone_statistics: Use hot node instead of cold zone_pgdat
Message-ID: <Pine.LNX.4.64.0609181949240.2078@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Now that we have the node in the hot zone of struct zone we can avoid accessing
zone_pgdat in zone_statistics.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.18-rc6-mm2/mm/vmstat.c
===================================================================
--- linux-2.6.18-rc6-mm2.orig/mm/vmstat.c	2006-09-18 21:24:50.000000000 -0500
+++ linux-2.6.18-rc6-mm2/mm/vmstat.c	2006-09-18 21:25:48.793059949 -0500
@@ -370,7 +370,7 @@ void zone_statistics(struct zonelist *zo
 		__inc_zone_state(z, NUMA_MISS);
 		__inc_zone_state(zonelist->zones[0], NUMA_FOREIGN);
 	}
-	if (z->zone_pgdat == NODE_DATA(numa_node_id()))
+	if (z->node == numa_node_id())
 		__inc_zone_state(z, NUMA_LOCAL);
 	else
 		__inc_zone_state(z, NUMA_OTHER);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
