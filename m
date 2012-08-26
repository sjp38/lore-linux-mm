Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 645666B006E
	for <linux-mm@kvack.org>; Sun, 26 Aug 2012 05:01:01 -0400 (EDT)
Received: from /spool/local
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Sun, 26 Aug 2012 14:30:57 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q7Q90tlZ2228730
	for <linux-mm@kvack.org>; Sun, 26 Aug 2012 14:30:55 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q7Q90s4S031070
	for <linux-mm@kvack.org>; Sun, 26 Aug 2012 19:00:54 +1000
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: [PATCH v2 4/4] mm/memblock: cleanup early_node_map[] related comments  
Date: Sun, 26 Aug 2012 17:00:26 +0800
Message-Id: <1345971626-17090-4-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1345971626-17090-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1345971626-17090-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Gavin Shan <shangw@linux.vnet.ibm.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>

From: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Commit 0ee332c14518699 ("memblock: Kill early_node_map[]") removed
early_node_map[], the patch does cleanup on comments to comply with
that change.

Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
---
 include/linux/memblock.h |    3 +--
 mm/nobootmem.c           |    2 --
 mm/page_alloc.c          |    2 +-
 3 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index d3d53aa..ab7b887 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -70,8 +70,7 @@ void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
  * @p_end: ptr to ulong for end pfn of the range, can be %NULL
  * @p_nid: ptr to int for nid of the range, can be %NULL
  *
- * Walks over configured memory ranges.  Available after early_node_map is
- * populated.
+ * Walks over configured memory ranges.
  */
 #define for_each_mem_pfn_range(i, nid, p_start, p_end, p_nid)		\
 	for (i = -1, __next_mem_pfn_range(&i, nid, p_start, p_end, p_nid); \
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 8ec48484..7e95953 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -162,8 +162,6 @@ unsigned long __init free_all_bootmem(void)
 	 * We need to use MAX_NUMNODES instead of NODE_DATA(0)->node_id
 	 *  because in some case like Node0 doesn't have RAM installed
 	 *  low ram will be on Node1
-	 * Use MAX_NUMNODES will make sure all ranges in early_node_map[]
-	 *  will be used instead of only Node0 related
 	 */
 	return free_low_memory_core_early(MAX_NUMNODES);
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 009ac28..c1e2949 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4873,7 +4873,7 @@ void __init free_area_init_nodes(unsigned long *max_zone_pfn)
 			       zone_movable_pfn[i] << PAGE_SHIFT);
 	}
 
-	/* Print out the early_node_map[] */
+	/* Print out the early node map */
 	printk("Early memory node ranges\n");
 	for_each_mem_pfn_range(i, MAX_NUMNODES, &start_pfn, &end_pfn, &nid)
 		printk("  node %3d: [mem %#010lx-%#010lx]\n", nid,
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
