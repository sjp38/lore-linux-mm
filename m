Message-Id: <20080509152245.510691866@saeurebad.de>
References: <20080509151713.939253437@saeurebad.de>
Date: Fri, 09 May 2008 17:17:14 +0200
From: Johannes Weiner <hannes@saeurebad.de>
Subject: [PATCH 1/3] mm: Make NR_NODE_MEMBLKS global
Content-Disposition: inline; filename=global-NR_NODE_MEMBLKS.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Yinghai Lu <yhlu.kernel@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Bootmem needs to work on contiguous memory block quantities rather
than whole nodes.  So make the maxium number of blocks and the
resulting number of blocks per node available to generic code like
bootmem.

Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
---

 include/linux/numa.h |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

--- a/include/linux/numa.h
+++ b/include/linux/numa.h
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
