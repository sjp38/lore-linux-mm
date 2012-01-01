Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id B52EF6B0071
	for <linux-mm@kvack.org>; Sun,  1 Jan 2012 02:31:56 -0500 (EST)
Received: by iacb35 with SMTP id b35so33320864iac.14
        for <linux-mm@kvack.org>; Sat, 31 Dec 2011 23:31:56 -0800 (PST)
Date: Sat, 31 Dec 2011 23:31:53 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 4/5] memcg: enum lru_list lru
In-Reply-To: <alpine.LSU.2.00.1112312322200.18500@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1112312330460.18500@eggly.anvils>
References: <alpine.LSU.2.00.1112312322200.18500@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

Mostly we use "enum lru_list lru": change those few "l"s to "lru"s.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/memcontrol.c |   20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

--- mmotm.orig/mm/memcontrol.c	2011-12-30 21:23:28.000000000 -0800
+++ mmotm/mm/memcontrol.c	2011-12-30 21:29:03.695349263 -0800
@@ -704,14 +704,14 @@ mem_cgroup_zone_nr_lru_pages(struct mem_
 			unsigned int lru_mask)
 {
 	struct mem_cgroup_per_zone *mz;
-	enum lru_list l;
+	enum lru_list lru;
 	unsigned long ret = 0;
 
 	mz = mem_cgroup_zoneinfo(memcg, nid, zid);
 
-	for_each_lru(l) {
-		if (BIT(l) & lru_mask)
-			ret += mz->lru_size[l];
+	for_each_lru(lru) {
+		if (BIT(lru) & lru_mask)
+			ret += mz->lru_size[lru];
 	}
 	return ret;
 }
@@ -3687,10 +3687,10 @@ move_account:
 		mem_cgroup_start_move(memcg);
 		for_each_node_state(node, N_HIGH_MEMORY) {
 			for (zid = 0; !ret && zid < MAX_NR_ZONES; zid++) {
-				enum lru_list l;
-				for_each_lru(l) {
+				enum lru_list lru;
+				for_each_lru(lru) {
 					ret = mem_cgroup_force_empty_list(memcg,
-							node, zid, l);
+							node, zid, lru);
 					if (ret)
 						break;
 				}
@@ -4784,7 +4784,7 @@ static int alloc_mem_cgroup_per_zone_inf
 {
 	struct mem_cgroup_per_node *pn;
 	struct mem_cgroup_per_zone *mz;
-	enum lru_list l;
+	enum lru_list lru;
 	int zone, tmp = node;
 	/*
 	 * This routine is called against possible nodes.
@@ -4802,8 +4802,8 @@ static int alloc_mem_cgroup_per_zone_inf
 
 	for (zone = 0; zone < MAX_NR_ZONES; zone++) {
 		mz = &pn->zoneinfo[zone];
-		for_each_lru(l)
-			INIT_LIST_HEAD(&mz->lruvec.lists[l]);
+		for_each_lru(lru)
+			INIT_LIST_HEAD(&mz->lruvec.lists[lru]);
 		mz->usage_in_excess = 0;
 		mz->on_tree = false;
 		mz->memcg = memcg;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
