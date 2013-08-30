Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id CBB7A6B0033
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 23:36:48 -0400 (EDT)
Message-ID: <5220133E.4030204@huawei.com>
Date: Fri, 30 Aug 2013 11:36:30 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: [PATCH 1/5] mm/vmalloc: use N_MEMORY instead of N_HIGH_MEMORY
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, laijs@cn.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, zhangyanfei@cn.fujitsu.com, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Since commit 8219fc48a(mm: node_states: introduce N_MEMORY),
we introduced N_MEMORY, now N_MEMORY stands for the nodes that has any memory,
and N_HIGH_MEMORY stands for the nodes that has normal or high memory.

The code here need to handle with the nodes which have memory,
we should use N_MEMORY instead.

Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
---
 mm/vmalloc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 13a5495..1152947 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2573,7 +2573,7 @@ static void show_numa_info(struct seq_file *m, struct vm_struct *v)
 		for (nr = 0; nr < v->nr_pages; nr++)
 			counters[page_to_nid(v->pages[nr])]++;
 
-		for_each_node_state(nr, N_HIGH_MEMORY)
+		for_each_node_state(nr, N_MEMORY)
 			if (counters[nr])
 				seq_printf(m, " N%u=%u", nr, counters[nr]);
 	}
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
