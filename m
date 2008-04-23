Message-ID: <480E9E52.4080905@cn.fujitsu.com>
Date: Wed, 23 Apr 2008 10:26:26 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH] memcg: remove redundant initialization in mem_cgroup_create()
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

*mem has been zeroed, that means mem->info has already
been filled with 0.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 mm/memcontrol.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index eefa750..020e8f5 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1014,8 +1014,6 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
 
 	res_counter_init(&mem->res);
 
-	memset(&mem->info, 0, sizeof(mem->info));
-
 	for_each_node_state(node, N_POSSIBLE)
 		if (alloc_mem_cgroup_per_zone_info(mem, node))
 			goto free_out;
-- 1.5.4.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
