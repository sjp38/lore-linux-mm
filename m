Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 062906B004A
	for <linux-mm@kvack.org>; Tue, 13 Mar 2012 11:32:25 -0400 (EDT)
Received: by dakn40 with SMTP id n40so1095119dak.9
        for <linux-mm@kvack.org>; Tue, 13 Mar 2012 08:32:25 -0700 (PDT)
From: Kautuk Consul <consul.kautuk@gmail.com>
Subject: [PATCH 1/2] page_alloc.c: kill add_from_early_node_map
Date: Tue, 13 Mar 2012 11:32:00 -0400
Message-Id: <1331652720-3054-1-git-send-email-consul.kautuk@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tejun Heo <tj@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kautuk Consul <consul.kautuk@gmail.com>

No one seems to be calling add_from_early_node_map anywhere from the
kernel.

Also, deleting this function decreases page_alloc.o file size.

Signed-off-by: Kautuk Consul <consul.kautuk@gmail.com>
---
 include/linux/mm.h |    2 --
 mm/page_alloc.c    |   12 ------------
 2 files changed, 0 insertions(+), 14 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 17b27cd..d8c4339 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1291,8 +1291,6 @@ extern void get_pfn_range_for_nid(unsigned int nid,
 extern unsigned long find_min_pfn_with_active_regions(void);
 extern void free_bootmem_with_active_regions(int nid,
 						unsigned long max_low_pfn);
-int add_from_early_node_map(struct range *range, int az,
-				   int nr_range, int nid);
 extern void sparse_memory_present_with_active_regions(int nid);
 
 #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a13ded1..3171f4c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3925,18 +3925,6 @@ void __init free_bootmem_with_active_regions(int nid, unsigned long max_low_pfn)
 	}
 }
 
-int __init add_from_early_node_map(struct range *range, int az,
-				   int nr_range, int nid)
-{
-	unsigned long start_pfn, end_pfn;
-	int i;
-
-	/* need to go over early_node_map to find out good range for node */
-	for_each_mem_pfn_range(i, nid, &start_pfn, &end_pfn, NULL)
-		nr_range = add_range(range, az, nr_range, start_pfn, end_pfn);
-	return nr_range;
-}
-
 /**
  * sparse_memory_present_with_active_regions - Call memory_present for each active range
  * @nid: The node to call memory_present for. If MAX_NUMNODES, all nodes will be used.
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
