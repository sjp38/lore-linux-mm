Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 3A2E06B00EF
	for <linux-mm@kvack.org>; Fri, 25 May 2012 12:12:23 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so2502542pbb.14
        for <linux-mm@kvack.org>; Fri, 25 May 2012 09:12:22 -0700 (PDT)
From: Chen Baozi <baozich@gmail.com>
Subject: [PATCH] memcg: remove the unnecessary MEM_CGROUP_STAT_DATA
Date: Fri, 25 May 2012 16:11:41 +0800
Message-Id: <1337933501-3985-1-git-send-email-baozich@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Chen Baozi <baozich@gmail.com>

Since MEM_CGROUP_ON_MOVE has been removed, it comes to be redudant
to hold MEM_CGROUP_STAT_DATA to mark the end of data requires
synchronization.

Signed-off-by: Chen Baozi <baozich@gmail.com>
---
 mm/memcontrol.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f342778..446ca94 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -88,7 +88,6 @@ enum mem_cgroup_stat_index {
 	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon rss */
 	MEM_CGROUP_STAT_FILE_MAPPED,  /* # of pages charged as file rss */
 	MEM_CGROUP_STAT_SWAPOUT, /* # of pages, swapped out */
-	MEM_CGROUP_STAT_DATA, /* end of data requires synchronization */
 	MEM_CGROUP_STAT_NSTATS,
 };
 
@@ -2139,7 +2138,7 @@ static void mem_cgroup_drain_pcp_counter(struct mem_cgroup *memcg, int cpu)
 	int i;
 
 	spin_lock(&memcg->pcp_counter_lock);
-	for (i = 0; i < MEM_CGROUP_STAT_DATA; i++) {
+	for (i = 0; i < MEM_CGROUP_STAT_NSTATS; i++) {
 		long x = per_cpu(memcg->stat->count[i], cpu);
 
 		per_cpu(memcg->stat->count[i], cpu) = 0;
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
