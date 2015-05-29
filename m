Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 250946B0087
	for <linux-mm@kvack.org>; Fri, 29 May 2015 07:57:46 -0400 (EDT)
Received: by wivl4 with SMTP id l4so14970097wiv.1
        for <linux-mm@kvack.org>; Fri, 29 May 2015 04:57:45 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x4si3828603wjr.105.2015.05.29.04.57.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 29 May 2015 04:57:37 -0700 (PDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [RFC -v2 2/7] memcg: get rid of extern for functions in memcontrol.h
Date: Fri, 29 May 2015 13:57:20 +0200
Message-Id: <1432900645-8856-3-git-send-email-mhocko@suse.cz>
In-Reply-To: <1432900645-8856-1-git-send-email-mhocko@suse.cz>
References: <1432900645-8856-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Most of the exported functions in this header are not marked extern so
change the rest to follow the same style.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 include/linux/memcontrol.h | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 3d9d7ff0d93e..c3993b1728f7 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -301,10 +301,10 @@ struct lruvec *mem_cgroup_page_lruvec(struct page *, struct zone *);
 
 bool task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *memcg);
 
-extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
-extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
+struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
+struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
 
-extern struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *memcg);
+struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *memcg);
 static inline
 struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *css){
 	return css ? container_of(css, struct mem_cgroup, css) : NULL;
@@ -396,8 +396,8 @@ static inline int mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec)
 	return inactive * inactive_ratio < active;
 }
 
-extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
-					struct task_struct *p);
+void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
+				struct task_struct *p);
 
 static inline void mem_cgroup_oom_enable(void)
 {
@@ -689,8 +689,8 @@ static inline void sock_release_memcg(struct sock *sk)
 extern struct static_key memcg_kmem_enabled_key;
 
 extern int memcg_nr_cache_ids;
-extern void memcg_get_cache_ids(void);
-extern void memcg_put_cache_ids(void);
+void memcg_get_cache_ids(void);
+void memcg_put_cache_ids(void);
 
 /*
  * Helper macro to loop through all memcg-specific caches. Callers must still
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
