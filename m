Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id 3112A6B0035
	for <linux-mm@kvack.org>; Mon, 26 May 2014 03:09:37 -0400 (EDT)
Received: by mail-we0-f170.google.com with SMTP id u57so7701769wes.29
        for <linux-mm@kvack.org>; Mon, 26 May 2014 00:09:36 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id c4si15060767wiw.2.2014.05.26.00.09.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 26 May 2014 00:09:35 -0700 (PDT)
Message-ID: <5382E895.1010802@huawei.com>
Date: Mon, 26 May 2014 15:09:09 +0800
From: Zhang Zhen <zhenzhang.zhang@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mm/page_alloc: cleanup add_active_range() related comments
References: <1401087978-17505-1-git-send-email-zhenzhang.zhang@huawei.com>
In-Reply-To: <1401087978-17505-1-git-send-email-zhenzhang.zhang@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Tejun Heo <tj@kernel.org>
Cc: linux-mm@kvack.org

add_active_range() has been repalced by memblock_set_node().
Clean up the comments to comply with that change.

Signed-off-by: Zhang Zhen <zhenzhang.zhang@huawei.com>
---
 mm/page_alloc.c | 21 ++++++++-------------
 1 file changed, 8 insertions(+), 13 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5dba293..a049e38 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4349,9 +4349,6 @@ int __meminit init_currently_empty_zone(struct zone *zone,
 #ifndef CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID
 /*
  * Required by SPARSEMEM. Given a PFN, return what node the PFN is on.
- * Architectures may implement their own version but if add_active_range()
- * was used and there are no special requirements, this is a convenient
- * alternative
  */
 int __meminit __early_pfn_to_nid(unsigned long pfn)
 {
@@ -4406,10 +4403,9 @@ bool __meminit early_pfn_in_nid(unsigned long pfn, int node)
  * @nid: The node to free memory on. If MAX_NUMNODES, all nodes are freed.
  * @max_low_pfn: The highest PFN that will be passed to memblock_free_early_nid
  *
- * If an architecture guarantees that all ranges registered with
- * add_active_ranges() contain no holes and may be freed, this
- * this function may be used instead of calling memblock_free_early_nid()
- * manually.
+ * If an architecture guarantees that all ranges registered contain no holes
+ * and may be freed, this this function may be used instead of calling
+ * memblock_free_early_nid() manually.
  */
 void __init free_bootmem_with_active_regions(int nid, unsigned long max_low_pfn)
 {
@@ -4431,9 +4427,8 @@ void __init free_bootmem_with_active_regions(int nid, unsigned long max_low_pfn)
  * sparse_memory_present_with_active_regions - Call memory_present for each active range
  * @nid: The node to call memory_present for. If MAX_NUMNODES, all nodes will be used.
  *
- * If an architecture guarantees that all ranges registered with
- * add_active_ranges() contain no holes and may be freed, this
- * function may be used instead of calling memory_present() manually.
+ * If an architecture guarantees that all ranges registered contain no holes and may
+ * be freed, this function may be used instead of calling memory_present() manually.
  */
 void __init sparse_memory_present_with_active_regions(int nid)
 {
@@ -4451,7 +4446,7 @@ void __init sparse_memory_present_with_active_regions(int nid)
  * @end_pfn: Passed by reference. On return, it will have the node end_pfn.
  *
  * It returns the start and end page frame of a node based on information
- * provided by an arch calling add_active_range(). If called for a node
+ * provided by memblock_set_node(). If called for a node
  * with no available memory, a warning is printed and the start and end
  * PFNs will be 0.
  */
@@ -5030,7 +5025,7 @@ static unsigned long __init find_min_pfn_for_node(int nid)
  * find_min_pfn_with_active_regions - Find the minimum PFN registered
  *
  * It returns the minimum PFN based on information provided via
- * add_active_range().
+ * memblock_set_node().
  */
 unsigned long __init find_min_pfn_with_active_regions(void)
 {
@@ -5251,7 +5246,7 @@ static void check_for_memory(pg_data_t *pgdat, int nid)
  * @max_zone_pfn: an array of max PFNs for each zone
  *
  * This will call free_area_init_node() for each active node in the system.
- * Using the page ranges provided by add_active_range(), the size of each
+ * Using the page ranges provided by memblock_set_node(), the size of each
  * zone in each node and their holes is calculated. If the maximum PFN
  * between two adjacent zones match, it is assumed that the zone is empty.
  * For example, if arch_max_dma_pfn == arch_max_dma32_pfn, it is assumed
-- 
1.8.1.2


.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
