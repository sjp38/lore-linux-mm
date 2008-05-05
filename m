Message-Id: <20080505100846.142962623@symbol.fehenstaub.lan>
References: <20080505095938.326928514@symbol.fehenstaub.lan>
Date: Mon, 05 May 2008 11:59:39 +0200
From: Johannes Weiner <hannes@saeurebad.de>
Subject: [rfc][patch 1/3] mm: Define NR_NODE_MEMBLKS unconditionally
Content-Disposition: inline; filename=nr_node_memblks.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Yinghai Lu <yhlu.kernel@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Yasunori Goto <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Bootmem needs to work on contiguous memory block quantities rather
than whole nodes, for the latter may overlap.  So make this maxium
number and the resulting number of blocks per node available to
generic code like bootmem.

Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
---

Index: linux-2.6/include/linux/numa.h
===================================================================
--- linux-2.6.orig/include/linux/numa.h
+++ linux-2.6/include/linux/numa.h
@@ -1,13 +1,17 @@
 #ifndef _LINUX_NUMA_H
 #define _LINUX_NUMA_H
 
-
 #ifdef CONFIG_NODES_SHIFT
-#define NODES_SHIFT     CONFIG_NODES_SHIFT
+#define NODES_SHIFT		CONFIG_NODES_SHIFT
 #else
-#define NODES_SHIFT     0
+#define NODES_SHIFT		0
 #endif
 
-#define MAX_NUMNODES    (1 << NODES_SHIFT)
+#define MAX_NUMNODES		(1 << NODES_SHIFT)
+
+#ifndef NR_NODE_MEMBLKS
+#define NR_NODE_MEMBLKS		MAX_NUMNODES
+#endif
+#define NR_MEMBLKS_PER_NODE	(NR_NODE_MEMBLKS / MAX_NUMNODES)
 
 #endif /* _LINUX_NUMA_H */

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
