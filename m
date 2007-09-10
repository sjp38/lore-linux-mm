Subject: [PATCH] 2.6.23-rc4-mm1:  memoryless nodes - cleanup "unused
	variable" warning
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Mon, 10 Sep 2007 12:43:52 -0400
Message-Id: <1189442632.5333.21.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

PATCH 2.6.23-rc4-mm1 - remove unused pgdat variable

When I replaced the for loop in page_alloc.c:find_next_best_node()
to scan only nodes with memory, the variable pgdat became unused.
I forgot to remove it and didn't notice the warning in the log.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/page_alloc.c |    1 -
 1 file changed, 1 deletion(-)

Index: Linux/mm/page_alloc.c
===================================================================
--- Linux.orig/mm/page_alloc.c	2007-09-10 12:21:31.000000000 -0400
+++ Linux/mm/page_alloc.c	2007-09-10 12:22:23.000000000 -0400
@@ -2130,7 +2130,6 @@ static int find_next_best_node(int node,
 	}
 
 	for_each_node_state(n, N_HIGH_MEMORY) {
-		pg_data_t *pgdat = NODE_DATA(n);
 		cpumask_t tmp;
 
 		/* Don't want a node to appear more than once */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
