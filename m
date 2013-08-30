Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 210C56B0033
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 23:38:45 -0400 (EDT)
Message-ID: <522013B9.3040609@huawei.com>
Date: Fri, 30 Aug 2013 11:38:33 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 2/5] mm/sparse: use N_MEMORY instead of N_HIGH_MEMORY
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, laijs@cn.fujitsu.com
Cc: Wen Congyang <wency@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Since commit 8219fc48a(mm: node_states: introduce N_MEMORY),
we introduced N_MEMORY, now N_MEMORY stands for the nodes that has any memory,
and N_HIGH_MEMORY stands for the nodes that has normal or high memory.

The code here need to handle with the nodes which have memory,
we should use N_MEMORY instead.

Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
---
 mm/sparse.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/sparse.c b/mm/sparse.c
index 308d503..8519d6a 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -64,7 +64,7 @@ static struct mem_section noinline __init_refok *sparse_index_alloc(int nid)
 				   sizeof(struct mem_section);
 
 	if (slab_is_available()) {
-		if (node_state(nid, N_HIGH_MEMORY))
+		if (node_state(nid, N_MEMORY))
 			section = kzalloc_node(array_size, GFP_KERNEL, nid);
 		else
 			section = kzalloc(array_size, GFP_KERNEL);
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
