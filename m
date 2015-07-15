Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id C44E128027E
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 07:15:17 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so37792126wib.0
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 04:15:17 -0700 (PDT)
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com. [209.85.212.179])
        by mx.google.com with ESMTPS id i8si8493307wiy.38.2015.07.15.04.15.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 04:15:16 -0700 (PDT)
Received: by widic2 with SMTP id ic2so60740136wid.0
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 04:15:15 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 3/5] memcg: get rid of extern for functions in memcontrol.h
Date: Wed, 15 Jul 2015 13:14:43 +0200
Message-Id: <1436958885-18754-4-git-send-email-mhocko@kernel.org>
In-Reply-To: <1436958885-18754-1-git-send-email-mhocko@kernel.org>
References: <1436958885-18754-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>

From: Michal Hocko <mhocko@suse.cz>

Most of the exported functions in this header are not marked extern so
change the rest to follow the same style.

Reviewed-by: Vladimir Davydov <vdavydov@parallels.com>
Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 include/linux/memcontrol.h | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 292e6701f3fd..ce85bdb556f5 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -305,10 +305,10 @@ struct lruvec *mem_cgroup_page_lruvec(struct page *, struct zone *);
 
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
@@ -343,7 +343,7 @@ static inline bool mm_match_cgroup(struct mm_struct *mm,
 	return match;
 }
 
-extern struct cgroup_subsys_state *mem_cgroup_css_from_page(struct page *page);
+struct cgroup_subsys_state *mem_cgroup_css_from_page(struct page *page);
 
 static inline bool mem_cgroup_disabled(void)
 {
@@ -402,8 +402,8 @@ static inline int mem_cgroup_inactive_anon_is_low(struct lruvec *lruvec)
 	return inactive * inactive_ratio < active;
 }
 
-extern void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
-					struct task_struct *p);
+void mem_cgroup_print_oom_info(struct mem_cgroup *memcg,
+				struct task_struct *p);
 
 static inline void mem_cgroup_oom_enable(void)
 {
@@ -718,8 +718,8 @@ static inline void sock_release_memcg(struct sock *sk)
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
