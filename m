Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 882926B0085
	for <linux-mm@kvack.org>; Sun,  1 Jan 2012 02:33:28 -0500 (EST)
Received: by iacb35 with SMTP id b35so33322230iac.14
        for <linux-mm@kvack.org>; Sat, 31 Dec 2011 23:33:28 -0800 (PST)
Date: Sat, 31 Dec 2011 23:33:24 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 5/5] memcg: remove redundant returns
In-Reply-To: <alpine.LSU.2.00.1112312322200.18500@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1112312331590.18500@eggly.anvils>
References: <alpine.LSU.2.00.1112312322200.18500@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

Remove redundant returns from ends of functions, and one blank line.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/memcontrol.c |    5 -----
 1 file changed, 5 deletions(-)

--- mmotm.orig/mm/memcontrol.c	2011-12-30 21:29:03.695349263 -0800
+++ mmotm/mm/memcontrol.c	2011-12-30 21:29:37.611350065 -0800
@@ -1362,7 +1362,6 @@ void mem_cgroup_print_oom_info(struct me
 	if (!memcg || !p)
 		return;
 
-
 	rcu_read_lock();
 
 	mem_cgrp = memcg->css.cgroup;
@@ -1897,7 +1896,6 @@ out:
 	if (unlikely(need_unlock))
 		move_unlock_page_cgroup(pc, &flags);
 	rcu_read_unlock();
-	return;
 }
 EXPORT_SYMBOL(mem_cgroup_update_page_stat);
 
@@ -2691,7 +2689,6 @@ __mem_cgroup_commit_charge_lrucare(struc
 		SetPageLRU(page);
 	}
 	spin_unlock_irqrestore(&zone->lru_lock, flags);
-	return;
 }
 
 int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
@@ -2881,7 +2878,6 @@ direct_uncharge:
 		res_counter_uncharge(&memcg->memsw, nr_pages * PAGE_SIZE);
 	if (unlikely(batch->memcg != memcg))
 		memcg_oom_recover(memcg);
-	return;
 }
 
 /*
@@ -3935,7 +3931,6 @@ static void memcg_get_hierarchical_limit
 out:
 	*mem_limit = min_limit;
 	*memsw_limit = min_memsw_limit;
-	return;
 }
 
 static int mem_cgroup_reset(struct cgroup *cont, unsigned int event)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
