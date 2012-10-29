Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 811026B0088
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 11:48:18 -0400 (EDT)
From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [V5 PATCH 13/26] vmstat: use N_MEMORY instead N_HIGH_MEMORY
Date: Mon, 29 Oct 2012 23:21:03 +0800
Message-Id: <1351524078-20363-12-git-send-email-laijs@cn.fujitsu.com>
In-Reply-To: <1351523301-20048-1-git-send-email-laijs@cn.fujitsu.com>
References: <1351523301-20048-1-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, x86 maintainers <x86@kernel.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, Rusty Russell <rusty@rustcorp.com.au>, Yinghai Lu <yinghai@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki ISIMATU <isimatu.yasuaki@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

N_HIGH_MEMORY stands for the nodes that has normal or high memory.
N_MEMORY stands for the nodes that has any memory.

The code here need to handle with the nodes which have memory, we should
use N_MEMORY instead.

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
Acked-by: Christoph Lameter <cl@linux.com>
---
 mm/vmstat.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index c737057..1b5cacd 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -930,7 +930,7 @@ static int pagetypeinfo_show(struct seq_file *m, void *arg)
 	pg_data_t *pgdat = (pg_data_t *)arg;
 
 	/* check memoryless node */
-	if (!node_state(pgdat->node_id, N_HIGH_MEMORY))
+	if (!node_state(pgdat->node_id, N_MEMORY))
 		return 0;
 
 	seq_printf(m, "Page block order: %d\n", pageblock_order);
@@ -1292,7 +1292,7 @@ static int unusable_show(struct seq_file *m, void *arg)
 	pg_data_t *pgdat = (pg_data_t *)arg;
 
 	/* check memoryless node */
-	if (!node_state(pgdat->node_id, N_HIGH_MEMORY))
+	if (!node_state(pgdat->node_id, N_MEMORY))
 		return 0;
 
 	walk_zones_in_node(m, pgdat, unusable_show_print);
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
