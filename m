Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 4ED6E6B0002
	for <linux-mm@kvack.org>; Mon, 11 Feb 2013 03:04:31 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 1/2] memcg: fast hierarchy-aware child test fix
Date: Mon, 11 Feb 2013 12:04:48 +0400
Message-Id: <1360569889-843-2-git-send-email-glommer@parallels.com>
In-Reply-To: <1360569889-843-1-git-send-email-glommer@parallels.com>
References: <1360569889-843-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com

---
 mm/memcontrol.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 25ac5f4..28252c9 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -5883,8 +5883,7 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
 
 	mutex_lock(&memcg_create_mutex);
 	/* oom-kill-disable is a flag for subhierarchy. */
-	if ((parent->use_hierarchy) ||
-	    (memcg->use_hierarchy && !list_empty(&cgrp->children))) {
+	if ((parent->use_hierarchy) || memcg_has_children(memcg)) {
 		cgroup_unlock();
 		return -EINVAL;
 	}
-- 
1.8.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
