From: Nick Piggin <npiggin@suse.de>
Message-Id: <20060408134657.22479.89589.sendpatchset@linux.site>
In-Reply-To: <20060408134635.22479.79269.sendpatchset@linux.site>
References: <20060408134635.22479.79269.sendpatchset@linux.site>
Subject: [patch 2/3] radix-tree: small
Date: Tue, 20 Jun 2006 16:48:38 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrew Morton <akpm@osdl.org>, Paul McKenney <Paul.McKenney@us.ibm.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Reduce radix tree node memory usage by about a factor of 4 for small
files (< 64K). There are pointer traversal and memory usage costs for
large files with dense pagecache.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/lib/radix-tree.c
===================================================================
--- linux-2.6.orig/lib/radix-tree.c
+++ linux-2.6/lib/radix-tree.c
@@ -33,7 +33,7 @@
 
 
 #ifdef __KERNEL__
-#define RADIX_TREE_MAP_SHIFT	6
+#define RADIX_TREE_MAP_SHIFT	(CONFIG_BASE_SMALL ? 4 : 6)
 #else
 #define RADIX_TREE_MAP_SHIFT	3	/* For more stressful testing */
 #endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
