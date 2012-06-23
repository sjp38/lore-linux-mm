Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id DF4236B0297
	for <linux-mm@kvack.org>; Sat, 23 Jun 2012 02:15:53 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so5514150pbb.14
        for <linux-mm@kvack.org>; Fri, 22 Jun 2012 23:15:53 -0700 (PDT)
From: Wanpeng Li <liwp.linux@gmail.com>
Subject: [PATCH 1/6] memcg: replace unsigned long by u64 to avoid overflow
Date: Sat, 23 Jun 2012 14:15:34 +0800
Message-Id: <1340432134-5178-1-git-send-email-liwp.linux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan@kernel.org>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Gavin Shan <shangw@linux.vnet.ibm.com>, Wanpeng Li <liwp.linux@gmail.com>

From: Wanpeng Li <liwp@linux.vnet.ibm.com>

Since the return value variable in mem_cgroup_zone_nr_lru_pages and
mem_cgroup_node_nr_lru_pages functions are u64, so replace the return
value of funtions by u64 to avoid overflow.

Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>
---
 mm/memcontrol.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a2677e0..724bd02 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -776,8 +776,7 @@ mem_cgroup_zone_nr_lru_pages(struct mem_cgroup *memcg, int nid, int zid,
 	return ret;
 }
 
-static unsigned long
-mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
+static u64 mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
 			int nid, unsigned int lru_mask)
 {
 	u64 total = 0;
@@ -790,7 +789,7 @@ mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
 	return total;
 }
 
-static unsigned long mem_cgroup_nr_lru_pages(struct mem_cgroup *memcg,
+static u64 mem_cgroup_nr_lru_pages(struct mem_cgroup *memcg,
 			unsigned int lru_mask)
 {
 	int nid;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
