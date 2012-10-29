Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 8E8116B0080
	for <linux-mm@kvack.org>; Mon, 29 Oct 2012 11:48:15 -0400 (EDT)
From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [V5 PATCH 16/26] vmscan: use N_MEMORY instead N_HIGH_MEMORY
Date: Mon, 29 Oct 2012 23:21:06 +0800
Message-Id: <1351524078-20363-15-git-send-email-laijs@cn.fujitsu.com>
In-Reply-To: <1351523301-20048-1-git-send-email-laijs@cn.fujitsu.com>
References: <1351523301-20048-1-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, x86 maintainers <x86@kernel.org>
Cc: Jiang Liu <jiang.liu@huawei.com>, Rusty Russell <rusty@rustcorp.com.au>, Yinghai Lu <yinghai@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki ISIMATU <isimatu.yasuaki@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Lai Jiangshan <laijs@cn.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

N_HIGH_MEMORY stands for the nodes that has normal or high memory.
N_MEMORY stands for the nodes that has any memory.

The code here need to handle with the nodes which have memory, we should
use N_MEMORY instead.

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
Acked-by: Hillf Danton <dhillf@gmail.com>
---
 mm/vmscan.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2624edc..98a2e11 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3135,7 +3135,7 @@ static int __devinit cpu_callback(struct notifier_block *nfb,
 	int nid;
 
 	if (action == CPU_ONLINE || action == CPU_ONLINE_FROZEN) {
-		for_each_node_state(nid, N_HIGH_MEMORY) {
+		for_each_node_state(nid, N_MEMORY) {
 			pg_data_t *pgdat = NODE_DATA(nid);
 			const struct cpumask *mask;
 
@@ -3191,7 +3191,7 @@ static int __init kswapd_init(void)
 	int nid;
 
 	swap_setup();
-	for_each_node_state(nid, N_HIGH_MEMORY)
+	for_each_node_state(nid, N_MEMORY)
  		kswapd_run(nid);
 	hotcpu_notifier(cpu_callback, 0);
 	return 0;
-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
