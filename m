Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 891346B0070
	for <linux-mm@kvack.org>; Thu,  5 Jul 2012 23:21:27 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so16721593pbb.14
        for <linux-mm@kvack.org>; Thu, 05 Jul 2012 20:21:26 -0700 (PDT)
From: Wanpeng Li <liwp.linux@gmail.com>
Subject: [PATCH] mm/memcg: mem_cgroup_relize_xxx_limit can guarantee memcg->res.limit <= memcg->memsw.limit
Date: Fri,  6 Jul 2012 11:21:00 +0800
Message-Id: <1341544860-5634-1-git-send-email-liwp.linux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwp.linux@gmail.com>

From: Wanpeng Li <liwp@linux.vnet.ibm.com>

Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>
---
 mm/memcontrol.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4b64fe0..a501660 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3418,7 +3418,7 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
 		/*
 		 * Rather than hide all in some function, I do this in
 		 * open coded manner. You see what this really does.
-		 * We have to guarantee memcg->res.limit < memcg->memsw.limit.
+		 * We have to guarantee memcg->res.limit <= memcg->memsw.limit.
 		 */
 		mutex_lock(&set_limit_mutex);
 		memswlimit = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
@@ -3479,7 +3479,7 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
 		/*
 		 * Rather than hide all in some function, I do this in
 		 * open coded manner. You see what this really does.
-		 * We have to guarantee memcg->res.limit < memcg->memsw.limit.
+		 * We have to guarantee memcg->res.limit <= memcg->memsw.limit.
 		 */
 		mutex_lock(&set_limit_mutex);
 		memlimit = res_counter_read_u64(&memcg->res, RES_LIMIT);
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
