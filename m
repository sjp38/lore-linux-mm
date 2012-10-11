Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 6A3676B002B
	for <linux-mm@kvack.org>; Thu, 11 Oct 2012 16:09:30 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so2429328pbb.14
        for <linux-mm@kvack.org>; Thu, 11 Oct 2012 13:09:29 -0700 (PDT)
Date: Thu, 11 Oct 2012 13:09:27 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, memcg: make mem_cgroup_out_of_memory static
Message-ID: <alpine.DEB.2.00.1210111307220.28062@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

mem_cgroup_out_of_memory() is only referenced from within file scope, so 
it can be marked static.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/oom.h |    2 --
 mm/memcontrol.c     |    4 ++--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -56,8 +56,6 @@ extern void check_panic_on_oom(enum oom_constraint constraint, gfp_t gfp_mask,
 extern enum oom_scan_t oom_scan_process_thread(struct task_struct *task,
 		unsigned long totalpages, const nodemask_t *nodemask,
 		bool force_kill);
-extern void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
-				     int order);
 
 extern void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 		int order, nodemask_t *mask, bool force_kill);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7acf43b..e4e9b18 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1465,8 +1465,8 @@ static u64 mem_cgroup_get_limit(struct mem_cgroup *memcg)
 	return min(limit, memsw);
 }
 
-void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
-			      int order)
+static void mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
+				     int order)
 {
 	struct mem_cgroup *iter;
 	unsigned long chosen_points = 0;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
