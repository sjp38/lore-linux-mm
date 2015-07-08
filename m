Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4B4A66B0256
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 08:28:15 -0400 (EDT)
Received: by wgck11 with SMTP id k11so194544122wgc.0
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 05:28:14 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id us6si3649033wjc.132.2015.07.08.05.28.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 08 Jul 2015 05:28:02 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 3/8] memcg: get rid of extern for functions in memcontrol.h
Date: Wed,  8 Jul 2015 14:27:47 +0200
Message-Id: <1436358472-29137-4-git-send-email-mhocko@kernel.org>
In-Reply-To: <1436358472-29137-1-git-send-email-mhocko@kernel.org>
References: <1436358472-29137-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Vladimir Davydov <vdavydov@parallels.com>, Greg Thelen <gthelen@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>

From: Michal Hocko <mhocko@suse.cz>

Most of the exported functions in this header are not marked extern so
change the rest to follow the same style.

Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 include/linux/memcontrol.h | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 680cefec8c2a..8818eee95f93 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -304,10 +304,10 @@ struct lruvec *mem_cgroup_page_lruvec(struct page *, struct zone *);
 
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
@@ -342,7 +342,7 @@ static inline bool mm_match_cgroup(struct mm_struct *mm,
 	return match;
 }
 
-extern struct cgroup_subsys_state *mem_cgroup_css_from_page(struct page *page);
+struct cgroup_subsys_state *mem_cgroup_css_from_page(struct page *page);
 
 static inline bool mem_cgroup_disabled(void)
 {
@@ -401,8 +401,8 @@ static inline int mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec)
 	return inactive * inactive_ratio < active;
 }
 
-extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
-					struct task_struct *p);
+void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
+				struct task_struct *p);
 
 static inline void mem_cgroup_oom_enable(void)
 {
@@ -717,8 +717,8 @@ static inline void sock_release_memcg(struct sock *sk)
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
