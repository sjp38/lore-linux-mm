Message-Id: <20070618192545.307157927@sgi.com>
References: <20070618191956.411091458@sgi.com>
Date: Mon, 18 Jun 2007 12:20:01 -0700
From: clameter@sgi.com
Subject: [patch 05/10] Memoryless Nodes: No need for kswapd
Content-Disposition: inline; filename=memless_no_kswapd
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Nishanth Aravamudan <nacc@us.ibm.com>
List-ID: <linux-mm.kvack.org>

A node without memory does not need a kswapd. So use the memory map instead
of the online map when starting kswapd.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Acked-by: Nishanth Aravamudan <nacc@us.ibm.com>

Index: linux-2.6.22-rc4-mm2/mm/vmscan.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/vmscan.c	2007-06-18 11:46:25.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/vmscan.c	2007-06-18 11:49:47.000000000 -0700
@@ -1735,7 +1735,7 @@ static int __init kswapd_init(void)
 	int nid;
 
 	swap_setup();
-	for_each_online_node(nid)
+	for_each_memory_node(nid)
  		kswapd_run(nid);
 	hotcpu_notifier(cpu_callback, 0);
 	return 0;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
