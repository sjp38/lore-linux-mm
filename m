Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id B9C896B0031
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 00:07:30 -0400 (EDT)
Message-ID: <52007660.7070907@huawei.com>
Date: Tue, 6 Aug 2013 12:06:56 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mm/mempolicy: return NULL if node is NUMA_NO_NODE in get_task_policy
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hanjun Guo <guohanjun@huawei.com>

If node == NUMA_NO_NODE, pol is NULL, we should return NULL instead of
do "if (!pol->mode)" check.

Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
---
 mm/mempolicy.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 4baf12e..e0e3398 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -129,6 +129,8 @@ static struct mempolicy *get_task_policy(struct task_struct *p)
 		node = numa_node_id();
 		if (node != NUMA_NO_NODE)
 			pol = &preferred_node_policy[node];
+		else
+			return NULL;
 
 		/* preferred_node_policy is not initialised early in boot */
 		if (!pol->mode)
-- 
1.8.2.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
