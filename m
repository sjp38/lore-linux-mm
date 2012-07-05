Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 405026B0070
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 20:35:49 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so14354437pbb.14
        for <linux-mm@kvack.org>; Wed, 04 Jul 2012 17:35:48 -0700 (PDT)
From: Wanpeng Li <liwp.linux@gmail.com>
Subject: [PATCH] mm/memcg: clarify type in memory cgroup
Date: Thu,  5 Jul 2012 08:35:28 +0800
Message-Id: <1341448528-3875-1-git-send-email-liwp.linux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwp.linux@gmail.com>

From: Wanpeng Li <liwp@linux.vnet.ibm.com>

Generally we use 'unsigned long' for number of pages and 'u64' for
number of bytes. But function mem_cgroup_zone_nr_lru_pages and
mem_cgroup_node_nr_lru_pages use local variable whose type is 'u64'
to caculate numbers of pages, however, the return value type of funtion
which describes the numbers of pages is 'unsigned long'. Replace 'u64'
by 'unsigned long' in order to clean up this inconsistent.

Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>
---
 mm/memcontrol.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f72b5e5..3d318f6 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -781,7 +781,7 @@ static unsigned long
 mem_cgroup_node_nr_lru_pages(struct mem_cgroup *memcg,
 			int nid, unsigned int lru_mask)
 {
-	u64 total = 0;
+	unsigned long total = 0;
 	int zid;
 
 	for (zid = 0; zid < MAX_NR_ZONES; zid++)
@@ -795,7 +795,7 @@ static unsigned long mem_cgroup_nr_lru_pages(struct mem_cgroup *memcg,
 			unsigned int lru_mask)
 {
 	int nid;
-	u64 total = 0;
+	unsigned long total = 0;
 
 	for_each_node_state(nid, N_HIGH_MEMORY)
 		total += mem_cgroup_node_nr_lru_pages(memcg, nid, lru_mask);
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
