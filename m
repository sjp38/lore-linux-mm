Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id C65486B005D
	for <linux-mm@kvack.org>; Fri, 23 Dec 2011 22:00:25 -0500 (EST)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [PATCH 2/6] memcg: mark more functions/variables as static
Date: Sat, 24 Dec 2011 05:00:15 +0200
Message-Id: <1324695619-5537-2-git-send-email-kirill@shutemov.name>
In-Reply-To: <1324695619-5537-1-git-send-email-kirill@shutemov.name>
References: <1324695619-5537-1-git-send-email-kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, cgroups@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, containers@lists.linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill@shutemov.name>

From: "Kirill A. Shutemov" <kirill@shutemov.name>

Based on sparse output.

Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
---
 mm/memcontrol.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index a5e92bd..4bac3a2 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -59,7 +59,7 @@
 
 struct cgroup_subsys mem_cgroup_subsys __read_mostly;
 #define MEM_CGROUP_RECLAIM_RETRIES	5
-struct mem_cgroup *root_mem_cgroup __read_mostly;
+static struct mem_cgroup *root_mem_cgroup __read_mostly;
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 /* Turned on only when memory cgroup is enabled && really_do_swap_account = 1 */
@@ -1573,7 +1573,7 @@ int mem_cgroup_select_victim_node(struct mem_cgroup *memcg)
  * unused nodes. But scan_nodes is lazily updated and may not cotain
  * enough new information. We need to do double check.
  */
-bool mem_cgroup_reclaimable(struct mem_cgroup *memcg, bool noswap)
+static bool mem_cgroup_reclaimable(struct mem_cgroup *memcg, bool noswap)
 {
 	int nid;
 
@@ -1608,7 +1608,7 @@ int mem_cgroup_select_victim_node(struct mem_cgroup *memcg)
 	return 0;
 }
 
-bool mem_cgroup_reclaimable(struct mem_cgroup *memcg, bool noswap)
+static bool mem_cgroup_reclaimable(struct mem_cgroup *memcg, bool noswap)
 {
 	return test_mem_cgroup_node_reclaimable(memcg, 0, noswap);
 }
@@ -1782,7 +1782,7 @@ static void memcg_oom_recover(struct mem_cgroup *memcg)
 /*
  * try to call OOM killer. returns false if we should exit memory-reclaim loop.
  */
-bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask)
+static bool mem_cgroup_handle_oom(struct mem_cgroup *memcg, gfp_t mask)
 {
 	struct oom_wait_info owait;
 	bool locked, need_to_kill;
@@ -3765,7 +3765,7 @@ try_to_free:
 	goto move_account;
 }
 
-int mem_cgroup_force_empty_write(struct cgroup *cont, unsigned int event)
+static int mem_cgroup_force_empty_write(struct cgroup *cont, unsigned int event)
 {
 	return mem_cgroup_force_empty(mem_cgroup_from_cont(cont), true);
 }
@@ -4044,7 +4044,7 @@ struct mcs_total_stat {
 	s64 stat[NR_MCS_STAT];
 };
 
-struct {
+static struct {
 	char *local_name;
 	char *total_name;
 } memcg_stat_strings[NR_MCS_STAT] = {
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
