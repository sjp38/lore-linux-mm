Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 5265B6B009F
	for <linux-mm@kvack.org>; Mon, 16 Sep 2013 08:53:36 -0400 (EDT)
Message-ID: <5236FF32.60503@huawei.com>
Date: Mon, 16 Sep 2013 20:53:06 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mm/mempolicy: use NUMA_NO_NODE
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Use more appropriate NUMA_NO_NODE instead of -1

Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
---
 mm/mempolicy.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 4baf12e..4f73025 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1083,7 +1083,7 @@ int do_migrate_pages(struct mm_struct *mm, const nodemask_t *from,
 	tmp = *from;
 	while (!nodes_empty(tmp)) {
 		int s,d;
-		int source = -1;
+		int source = NUMA_NO_NODE;
 		int dest = 0;
 
 		for_each_node_mask(s, tmp) {
@@ -1118,7 +1118,7 @@ int do_migrate_pages(struct mm_struct *mm, const nodemask_t *from,
 			if (!node_isset(dest, tmp))
 				break;
 		}
-		if (source == -1)
+		if (source == NUMA_NO_NODE)
 			break;
 
 		node_clear(source, tmp);
@@ -1765,7 +1765,7 @@ static unsigned offset_il_node(struct mempolicy *pol,
 	unsigned nnodes = nodes_weight(pol->v.nodes);
 	unsigned target;
 	int c;
-	int nid = -1;
+	int nid = NUMA_NO_NODE;
 
 	if (!nnodes)
 		return numa_node_id();
@@ -1802,11 +1802,11 @@ static inline unsigned interleave_nid(struct mempolicy *pol,
 
 /*
  * Return the bit number of a random bit set in the nodemask.
- * (returns -1 if nodemask is empty)
+ * (returns NUMA_NO_NOD if nodemask is empty)
  */
 int node_random(const nodemask_t *maskp)
 {
-	int w, bit = -1;
+	int w, bit = NUMA_NO_NODE;
 
 	w = nodes_weight(*maskp);
 	if (w)
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
