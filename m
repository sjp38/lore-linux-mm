Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6CFC46B0003
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 21:48:58 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id 101-v6so2099212ple.19
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 18:48:58 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e29-v6sor6108592plj.14.2018.03.07.18.48.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Mar 2018 18:48:57 -0800 (PST)
From: Shakeel Butt <shakeelb@google.com>
Subject: [PATCH] mm: memcg: expose mem_cgroup_put API
Date: Wed,  7 Mar 2018 18:48:50 -0800
Message-Id: <20180308024850.39737-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Shakeel Butt <shakeelb@google.com>

This patch exports mem_cgroup_put API to put the refcnt of the memory
cgroup.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
 include/linux/memcontrol.h | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index c46016bb25eb..0da79e116a07 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -344,6 +344,11 @@ struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *css){
 	return css ? container_of(css, struct mem_cgroup, css) : NULL;
 }
 
+static inline void mem_cgroup_put(struct mem_cgroup *memcg)
+{
+	css_put(&memcg->css);
+}
+
 #define mem_cgroup_from_counter(counter, member)	\
 	container_of(counter, struct mem_cgroup, member)
 
@@ -789,6 +794,10 @@ static inline bool task_in_mem_cgroup(struct task_struct *task,
 	return true;
 }
 
+static inline void mem_cgroup_put(struct mem_cgroup *memcg)
+{
+}
+
 static inline struct mem_cgroup *
 mem_cgroup_iter(struct mem_cgroup *root,
 		struct mem_cgroup *prev,
-- 
2.16.2.395.g2e18187dfd-goog
