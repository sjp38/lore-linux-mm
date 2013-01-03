Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 764B66B006C
	for <linux-mm@kvack.org>; Thu,  3 Jan 2013 16:36:16 -0500 (EST)
Received: by mail-pb0-f45.google.com with SMTP id mc8so8719131pbc.4
        for <linux-mm@kvack.org>; Thu, 03 Jan 2013 13:36:15 -0800 (PST)
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 01/13] cpuset: remove unused cpuset_unlock()
Date: Thu,  3 Jan 2013 13:35:55 -0800
Message-Id: <1357248967-24959-2-git-send-email-tj@kernel.org>
In-Reply-To: <1357248967-24959-1-git-send-email-tj@kernel.org>
References: <1357248967-24959-1-git-send-email-tj@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lizefan@huawei.com, paul@paulmenage.org, glommer@parallels.com
Cc: containers@lists.linux-foundation.org, cgroups@vger.kernel.org, peterz@infradead.org, mhocko@suse.cz, bsingharora@gmail.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>

Signed-off-by: Tejun Heo <tj@kernel.org>
---
 kernel/cpuset.c | 11 -----------
 1 file changed, 11 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 7bb63ee..854b8bf 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -2412,17 +2412,6 @@ int __cpuset_node_allowed_hardwall(int node, gfp_t gfp_mask)
 }
 
 /**
- * cpuset_unlock - release lock on cpuset changes
- *
- * Undo the lock taken in a previous cpuset_lock() call.
- */
-
-void cpuset_unlock(void)
-{
-	mutex_unlock(&callback_mutex);
-}
-
-/**
  * cpuset_mem_spread_node() - On which node to begin search for a file page
  * cpuset_slab_spread_node() - On which node to begin search for a slab page
  *
-- 
1.8.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
