Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 79E2D6B0033
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 23:41:33 -0400 (EDT)
Message-ID: <5220143A.808@huawei.com>
Date: Fri, 30 Aug 2013 11:40:42 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 3/5] mm/vmemmap: use N_MEMORY instead of N_HIGH_MEMORY
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, laijs@cn.fujitsu.com
Cc: Johannes Weiner <hannes@cmpxchg.org>, davem@davemloft.net, ben@decadent.org.uk, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Since commit 8219fc48a(mm: node_states: introduce N_MEMORY),
we introduced N_MEMORY, now N_MEMORY stands for the nodes that has any memory,
and N_HIGH_MEMORY stands for the nodes that has normal or high memory.

The code here need to handle with the nodes which have memory,
we should use N_MEMORY instead.

Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
---
 mm/sparse-vmemmap.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index 27eeab3..ca8f46b 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -52,7 +52,7 @@ void * __meminit vmemmap_alloc_block(unsigned long size, int node)
 	if (slab_is_available()) {
 		struct page *page;
 
-		if (node_state(node, N_HIGH_MEMORY))
+		if (node_state(node, N_MEMORY))
 			page = alloc_pages_node(
 				node, GFP_KERNEL | __GFP_ZERO | __GFP_REPEAT,
 				get_order(size));
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
