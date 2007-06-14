Message-Id: <20070614075334.990871341@sgi.com>
References: <20070614075026.607300756@sgi.com>
Date: Thu, 14 Jun 2007 00:50:30 -0700
From: clameter@sgi.com
Subject: [RFC 04/13] Memoryless Nodes: No need for kswapd
Content-Disposition: inline; filename=nodeless_no_kswapd
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

A node without memory does not need a kswapd. So use the memory map instead
of the online map to start kswapd.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.22-rc4-mm2/mm/vmscan.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/vmscan.c	2007-06-13 23:15:05.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/vmscan.c	2007-06-13 23:16:30.000000000 -0700
@@ -1716,7 +1716,7 @@ static int __init kswapd_init(void)
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
