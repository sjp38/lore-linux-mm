Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id D2CC06B0062
	for <linux-mm@kvack.org>; Fri, 23 Dec 2011 22:00:25 -0500 (EST)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCH 6/6] memcg: drop redundant brackets
Date: Sat, 24 Dec 2011 05:00:19 +0200
Message-Id: <1324695619-5537-6-git-send-email-kirill@shutemov.name>
In-Reply-To: <1324695619-5537-1-git-send-email-kirill@shutemov.name>
References: <1324695619-5537-1-git-send-email-kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, containers@lists.linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill@shutemov.name>

From: "Kirill A. Shutemov" <kirill@shutemov.name>

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
---
 mm/memcontrol.c |   28 ++++++++++++++--------------
 1 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3833a7b..48cba05 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -73,7 +73,7 @@ static int really_do_swap_account __initdata = 0;
 #endif
 
 #else
-#define do_swap_account		(0)
+#define do_swap_account		0
 #endif
 
 
@@ -113,9 +113,9 @@ enum mem_cgroup_events_target {
 	MEM_CGROUP_TARGET_NUMAINFO,
 	MEM_CGROUP_NTARGETS,
 };
-#define THRESHOLDS_EVENTS_TARGET (128)
-#define SOFTLIMIT_EVENTS_TARGET (1024)
-#define NUMAINFO_EVENTS_TARGET	(1024)
+#define THRESHOLDS_EVENTS_TARGET 128
+#define SOFTLIMIT_EVENTS_TARGET 1024
+#define NUMAINFO_EVENTS_TARGET	1024
 
 struct mem_cgroup_stat_cpu {
 	long count[MEM_CGROUP_STAT_NSTATS];
@@ -148,7 +148,7 @@ struct mem_cgroup_per_zone {
 						/* use container_of	   */
 };
 /* Macro for accessing counter */
-#define MEM_CGROUP_ZSTAT(mz, idx)	((mz)->count[(idx)])
+#define MEM_CGROUP_ZSTAT(mz, idx)	((mz)->count[idx])
 
 struct mem_cgroup_per_node {
 	struct mem_cgroup_per_zone zoneinfo[MAX_NR_ZONES];
@@ -346,8 +346,8 @@ static bool move_file(void)
  * Maximum loops in mem_cgroup_hierarchical_reclaim(), used for soft
  * limit reclaim to prevent infinite loops, if they ever occur.
  */
-#define	MEM_CGROUP_MAX_RECLAIM_LOOPS		(100)
-#define	MEM_CGROUP_MAX_SOFT_LIMIT_RECLAIM_LOOPS	(2)
+#define	MEM_CGROUP_MAX_RECLAIM_LOOPS		100
+#define	MEM_CGROUP_MAX_SOFT_LIMIT_RECLAIM_LOOPS	2
 
 enum charge_type {
 	MEM_CGROUP_CHARGE_TYPE_CACHE = 0,
@@ -368,11 +368,11 @@ enum mem_type {
 	_KMEM,
 };
 
-#define MEMFILE_PRIVATE(x, val)	(((x) << 16) | (val))
-#define MEMFILE_TYPE(val)	(((val) >> 16) & 0xffff)
+#define MEMFILE_PRIVATE(x, val)	((x) << 16 | (val))
+#define MEMFILE_TYPE(val)	((val) >> 16 & 0xffff)
 #define MEMFILE_ATTR(val)	((val) & 0xffff)
 /* Used for OOM nofiier */
-#define OOM_CONTROL		(0)
+#define OOM_CONTROL		0
 
 /*
  * Reclaim flags for mem_cgroup_hierarchical_reclaim
@@ -1913,7 +1913,7 @@ struct memcg_stock_pcp {
 	unsigned int nr_pages;
 	struct work_struct work;
 	unsigned long flags;
-#define FLUSHING_CACHED_CHARGE	(0)
+#define FLUSHING_CACHED_CHARGE	0
 };
 static DEFINE_PER_CPU(struct memcg_stock_pcp, memcg_stock);
 static DEFINE_MUTEX(percpu_charge_mutex);
@@ -2094,7 +2094,7 @@ static int __cpuinit memcg_cpu_hotplug_callback(struct notifier_block *nb,
 	struct memcg_stock_pcp *stock;
 	struct mem_cgroup *iter;
 
-	if ((action == CPU_ONLINE)) {
+	if (action == CPU_ONLINE) {
 		for_each_mem_cgroup(iter)
 			synchronize_mem_cgroup_on_move(iter, cpu);
 		return NOTIFY_OK;
@@ -2458,8 +2458,8 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *memcg,
 
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 
-#define PCGF_NOCOPY_AT_SPLIT ((1 << PCG_LOCK) | (1 << PCG_MOVE_LOCK) |\
-			(1 << PCG_MIGRATION))
+#define PCGF_NOCOPY_AT_SPLIT (1 << PCG_LOCK | 1 << PCG_MOVE_LOCK |\
+		1 << PCG_MIGRATION)
 /*
  * Because tail pages are not marked as "used", set it. We're under
  * zone->lru_lock, 'splitting on pmd' and compound_lock.
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
