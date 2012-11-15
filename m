Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 1D5BE6B00AE
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 03:51:35 -0500 (EST)
From: Wen Congyang <wency@cn.fujitsu.com>
Subject: [PART3 Patch v2 10/14] kthread: use N_MEMORY instead N_HIGH_MEMORY
Date: Thu, 15 Nov 2012 16:57:33 +0800
Message-Id: <1352969857-26623-11-git-send-email-wency@cn.fujitsu.com>
In-Reply-To: <1352969857-26623-1-git-send-email-wency@cn.fujitsu.com>
References: <1352969857-26623-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-doc@vger.kernel.org
Cc: Rob Landley <rob@landley.net>, Andrew Morton <akpm@linux-foundation.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Jiang Liu <jiang.liu@huawei.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Yinghai Lu <yinghai@kernel.org>, Rusty Russell <rusty@rustcorp.com.au>, Lin feng <linfeng@cn.fujitsu.com>, Wen Congyang <wency@cn.fujitsu.com>

From: Lai Jiangshan <laijs@cn.fujitsu.com>

N_HIGH_MEMORY stands for the nodes that has normal or high memory.
N_MEMORY stands for the nodes that has any memory.

The code here need to handle with the nodes which have memory, we should
use N_MEMORY instead.

Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>
Signed-off-by: Wen Congyang <wency@cn.fujitsu.com>
---
 kernel/kthread.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/kthread.c b/kernel/kthread.c
index 29fb60c..691dc2e 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -428,7 +428,7 @@ int kthreadd(void *unused)
 	set_task_comm(tsk, "kthreadd");
 	ignore_signals(tsk);
 	set_cpus_allowed_ptr(tsk, cpu_all_mask);
-	set_mems_allowed(node_states[N_HIGH_MEMORY]);
+	set_mems_allowed(node_states[N_MEMORY]);
 
 	current->flags |= PF_NOFREEZE;
 
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
