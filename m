Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 7319E6B0062
	for <linux-mm@kvack.org>; Mon,  6 Aug 2012 05:23:49 -0400 (EDT)
From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [RFC V3 PATCH 13/25] vmstat: use N_MEMORY instead N_HIGH_MEMORY
Date: Mon, 6 Aug 2012 17:23:07 +0800
Message-Id: <1344244999-5081-14-git-send-email-laijs@cn.fujitsu.com>
In-Reply-To: <1344244999-5081-1-git-send-email-laijs@cn.fujitsu.com>
References: <1343887288-8866-1-git-send-email-laijs@cn.fujitsu.com>
 <1344244999-5081-1-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org
Cc: Lai Jiangshan <laijs@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org

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
index 1bbbbd9..aa3da12 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -917,7 +917,7 @@ static int pagetypeinfo_show(struct seq_file *m, void *arg)
 	pg_data_t *pgdat = (pg_data_t *)arg;
 
 	/* check memoryless node */
-	if (!node_state(pgdat->node_id, N_HIGH_MEMORY))
+	if (!node_state(pgdat->node_id, N_MEMORY))
 		return 0;
 
 	seq_printf(m, "Page block order: %d\n", pageblock_order);
@@ -1279,7 +1279,7 @@ static int unusable_show(struct seq_file *m, void *arg)
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
