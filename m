Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id AC48D6B0095
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 13:55:02 -0500 (EST)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH 1/7] memcg: simplify ida initialization
Date: Thu, 15 Nov 2012 06:54:47 +0400
Message-Id: <1352948093-2315-2-git-send-email-glommer@parallels.com>
In-Reply-To: <1352948093-2315-1-git-send-email-glommer@parallels.com>
References: <1352948093-2315-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Glauber Costa <glommer@parallels.com>

As suggested by akpm, change the manual initialization of our kmem
index to DEFINE_IDA()

Signed-off-by: Glauber Costa <glommer@parallels.com>
CC: Michal Hocko <mhocko@suse.cz>
CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Johannes Weiner <hannes@cmpxchg.org>
CC: Andrew Morton <akpm@linux-foundation.org>
---
 mm/memcontrol.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6136fec..c0c6adf 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -569,7 +569,7 @@ static void disarm_sock_keys(struct mem_cgroup *memcg)
  * memcg_limited_groups_array_size.  It will double each time we have to
  * increase it.
  */
-static struct ida kmem_limited_groups;
+static DEFINE_IDA(kmem_limited_groups);
 int memcg_limited_groups_array_size;
 
 /*
@@ -5686,9 +5686,6 @@ static int memcg_init_kmem(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
 	if (ret)
 		return ret;
 
-	if (mem_cgroup_is_root(memcg))
-		ida_init(&kmem_limited_groups);
-
 	return mem_cgroup_sockets_init(memcg, ss);
 };
 
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
