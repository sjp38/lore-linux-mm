Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 2E65D6B0062
	for <linux-mm@kvack.org>; Fri, 29 Jun 2012 17:06:52 -0400 (EDT)
Received: by dakp5 with SMTP id p5so5982294dak.14
        for <linux-mm@kvack.org>; Fri, 29 Jun 2012 14:06:51 -0700 (PDT)
Date: Fri, 29 Jun 2012 14:06:49 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 1/5] mm, oom: move declaration for mem_cgroup_out_of_memory
 to oom.h
In-Reply-To: <alpine.DEB.2.00.1206251846020.24838@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1206291404530.6040@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1206251846020.24838@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan@kernel.org>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, cgroups@vger.kernel.org

mem_cgroup_out_of_memory() is defined in mm/oom_kill.c, so declare it in
linux/oom.h rather than linux/memcontrol.h.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Acked-by: Michal Hocko <mhocko@suse.cz>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/memcontrol.h |    2 --
 include/linux/oom.h        |    2 ++
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -72,8 +72,6 @@ extern void mem_cgroup_uncharge_end(void);
 extern void mem_cgroup_uncharge_page(struct page *page);
 extern void mem_cgroup_uncharge_cache_page(struct page *page);
 
-extern void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
-				     int order);
 bool __mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
 				  struct mem_cgroup *memcg);
 int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *memcg);
diff --git a/include/linux/oom.h b/include/linux/oom.h
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -49,6 +49,8 @@ extern unsigned long oom_badness(struct task_struct *p,
 extern int try_set_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
 extern void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_flags);
 
+extern void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
+				     int order);
 extern void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		int order, nodemask_t *mask, bool force_kill);
 extern int register_oom_notifier(struct notifier_block *nb);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
