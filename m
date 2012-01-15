Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 49B976B0062
	for <linux-mm@kvack.org>; Sat, 14 Jan 2012 19:14:48 -0500 (EST)
Received: by iafj26 with SMTP id j26so8437317iaf.14
        for <linux-mm@kvack.org>; Sat, 14 Jan 2012 16:14:47 -0800 (PST)
Date: Sat, 14 Jan 2012 16:14:40 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 5/5] memcg: remove redundant returns
In-Reply-To: <alpine.LSU.2.00.1201141550170.1261@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1201141613370.1261@eggly.anvils>
References: <alpine.LSU.2.00.1112312322200.18500@eggly.anvils> <20120109130259.GD3588@cmpxchg.org> <alpine.LSU.2.00.1201141550170.1261@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org

Remove redundant returns from ends of functions, and one blank line.

Signed-off-by: Hugh Dickins <hughd@google.com>
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Acked-by: Kirill A. Shutemov <kirill@shutemov.name>
Acked-by: Michal Hocko <mhocko@suse.cz>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
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
