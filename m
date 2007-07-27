From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 27 Jul 2007 15:43:48 -0400
Message-Id: <20070727194348.18614.72206.sendpatchset@localhost>
In-Reply-To: <20070727194316.18614.36380.sendpatchset@localhost>
References: <20070727194316.18614.36380.sendpatchset@localhost>
Subject: [PATCH 05/14] Memoryless Nodes: No need for kswapd
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: ak@suse.de, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Christoph Lameter <clameter@sgi.com>, Mel Gorman <mel@skynet.ie>, akpm@linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

[patch 05/14] Memoryless Nodes: No need for kswapd

A node without memory does not need a kswapd. So use the memory map instead
of the online map when starting kswapd.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Acked-by: Nishanth Aravamudan <nacc@us.ibm.com>
Tested-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
Acked-by: Lee Schermerhorn <lee.schermerhorn@hp.com>
Acked-by: Bob Picco <bob.picco@hp.com>

 mm/vmscan.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: Linux/mm/vmscan.c
===================================================================
--- Linux.orig/mm/vmscan.c	2007-07-25 09:29:50.000000000 -0400
+++ Linux/mm/vmscan.c	2007-07-25 11:36:35.000000000 -0400
@@ -1716,7 +1716,7 @@ static int __init kswapd_init(void)
 	int nid;
 
 	swap_setup();
-	for_each_online_node(nid)
+	for_each_node_state(nid, N_MEMORY)
  		kswapd_run(nid);
 	hotcpu_notifier(cpu_callback, 0);
 	return 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
