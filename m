Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 013B96B0083
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 03:58:36 -0400 (EDT)
From: Wen Congyang <wency@cn.fujitsu.com>
Subject: [PART3 Patch 12/14] vmscan: use N_MEMORY instead N_HIGH_MEMORY
Date: Wed, 31 Oct 2012 16:04:10 +0800
Message-Id: <1351670652-9932-13-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1351670652-9932-1-git-send-email-wency@cn.fujitsu.com>
References: <1351670652-9932-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org
Cc: Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Yinghai Lu <yinghai@kernel.org>, "rusty@rustcorp.com.au" <rusty@rustcorp.com.au>

From: Lai Jiangshan <laijs@cn.fujitsu.com>

N_HIGH_MEMORY stands for the nodes that has normal or high memory.
N_MEMORY stands for the nodes that has any memory.

The code here need to handle with the nodes which have memory, we should
use N_MEMORY instead.

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
Acked-by: Hillf Danton <dhillf@gmail.com>
---
 mm/vmscan.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

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
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
