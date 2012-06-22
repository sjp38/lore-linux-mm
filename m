Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id C8CEA6B0169
	for <linux-mm@kvack.org>; Fri, 22 Jun 2012 08:00:08 -0400 (EDT)
Received: by dakp5 with SMTP id p5so2776072dak.14
        for <linux-mm@kvack.org>; Fri, 22 Jun 2012 05:00:08 -0700 (PDT)
From: Wanpeng Li <liwp.linux@gmail.com>
Subject: [PATCH 1/2] memcg: use existing function to judge root mem cgroup
Date: Fri, 22 Jun 2012 19:57:22 +0800
Message-Id: <1340366243-28104-1-git-send-email-liwp.linux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: cgroups@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Han Ying <yinghan@google.com>, Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Wanpeng Li <liwp.linux@gmail.com>

From: Wanpeng Li <liwp@linux.vnet.ibm.com>

Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>
---
 mm/memcontrol.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f72b5e5..776fc57 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -4873,7 +4873,7 @@ mem_cgroup_create(struct cgroup *cont)
 			goto free_out;
 
 	/* root ? */
-	if (cont->parent == NULL) {
+	if (!(mem_cgroup_is_root(cont))) {
 		int cpu;
 		enable_swap_cgroup();
 		parent = NULL;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
