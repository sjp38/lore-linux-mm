Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 874396B0261
	for <linux-mm@kvack.org>; Fri,  6 May 2016 17:23:44 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 4so252466198pfw.0
        for <linux-mm@kvack.org>; Fri, 06 May 2016 14:23:44 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id n73si19809137pfj.132.2016.05.06.14.23.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 May 2016 14:23:43 -0700 (PDT)
Received: by mail-pa0-x230.google.com with SMTP id r5so52472555pag.1
        for <linux-mm@kvack.org>; Fri, 06 May 2016 14:23:43 -0700 (PDT)
From: Greg Thelen <gthelen@google.com>
Subject: [PATCH] memcg: fix stale mem_cgroup_force_empty() comment
Date: Fri,  6 May 2016 14:23:30 -0700
Message-Id: <1462569810-54496-1-git-send-email-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Greg Thelen <gthelen@google.com>

commit f61c42a7d911 ("memcg: remove tasks/children test from
mem_cgroup_force_empty()") removed memory reparenting from the function.

Fix the function's comment.

Signed-off-by: Greg Thelen <gthelen@google.com>
---
 mm/memcontrol.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index fe787f5c41bd..19fd76168a05 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2636,8 +2636,7 @@ static inline bool memcg_has_children(struct mem_cgroup *memcg)
 }
 
 /*
- * Reclaims as many pages from the given memcg as possible and moves
- * the rest to the parent.
+ * Reclaims as many pages from the given memcg as possible.
  *
  * Caller is responsible for holding css reference for memcg.
  */
-- 
2.8.0.rc3.226.g39d4020

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
