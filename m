Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2FE0B6B0003
	for <linux-mm@kvack.org>; Fri, 22 Jun 2018 20:06:39 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f19-v6so813021edq.22
        for <linux-mm@kvack.org>; Fri, 22 Jun 2018 17:06:39 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id h88-v6si4932869edc.133.2018.06.22.17.06.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Jun 2018 17:06:37 -0700 (PDT)
From: Roman Gushchin <guro@fb.com>
Subject: [PATCH 1/2] mm: revert mem_cgroup_put() introduction
Date: Fri, 22 Jun 2018 17:05:59 -0700
Message-ID: <20180623000600.5818-1-guro@fb.com>
In-Reply-To: <CALvZod7G-ggYTpmdDsNeQRf4upYa34ccOerVmEkEkLOVFrBr2w@mail.gmail.com>
References: <CALvZod7G-ggYTpmdDsNeQRf4upYa34ccOerVmEkEkLOVFrBr2w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, shakeelb@google.com, hannes@cmpxchg.org, mhocko@kernel.org, akpm@linux-foundation.org, Roman Gushchin <guro@fb.com>

This patch should be folded into "mm, oom: cgroup-aware OOM killer".

Signed-off-by: Roman Gushchin <guro@fb.com>
---
 include/linux/memcontrol.h | 9 ---------
 1 file changed, 9 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 3607913032be..cf1c3555328f 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -383,11 +383,6 @@ struct mem_cgroup *mem_cgroup_from_css(struct cgroup_subsys_state *css){
 	return css ? container_of(css, struct mem_cgroup, css) : NULL;
 }
 
-static inline void mem_cgroup_put(struct mem_cgroup *memcg)
-{
-	css_put(&memcg->css);
-}
-
 #define mem_cgroup_from_counter(counter, member)	\
 	container_of(counter, struct mem_cgroup, member)
 
@@ -857,10 +852,6 @@ static inline bool task_in_mem_cgroup(struct task_struct *task,
 	return true;
 }
 
-static inline void mem_cgroup_put(struct mem_cgroup *memcg)
-{
-}
-
 static inline struct mem_cgroup *
 mem_cgroup_iter(struct mem_cgroup *root,
 		struct mem_cgroup *prev,
-- 
2.14.4
