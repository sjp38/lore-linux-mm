Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id D119D6B000A
	for <linux-mm@kvack.org>; Mon, 11 Feb 2013 03:04:44 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 2/2] memcg: replace cgroup_lock with memcg specific memcg_lock fix
Date: Mon, 11 Feb 2013 12:04:49 +0400
Message-Id: <1360569889-843-3-git-send-email-glommer@parallels.com>
In-Reply-To: <1360569889-843-1-git-send-email-glommer@parallels.com>
References: <1360569889-843-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Glauber Costa <glommer@parallels.com>

Signed-off-by: Glauber Costa <glommer@parallels.com>
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
---
 mm/memcontrol.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 28252c9..03ebf68 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5884,7 +5884,7 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
 	mutex_lock(&memcg_create_mutex);
 	/* oom-kill-disable is a flag for subhierarchy. */
 	if ((parent->use_hierarchy) || memcg_has_children(memcg)) {
-		cgroup_unlock();
+		mutex_unlock(&memcg_create_mutex);
 		return -EINVAL;
 	}
 	memcg->oom_kill_disable = val;
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
