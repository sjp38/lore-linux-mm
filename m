Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E6C506B0078
	for <linux-mm@kvack.org>; Sun,  5 Sep 2010 14:33:17 -0400 (EDT)
Received: by ewy28 with SMTP id 28so2392976ewy.14
        for <linux-mm@kvack.org>; Sun, 05 Sep 2010 11:33:18 -0700 (PDT)
From: Kulikov Vasiliy <segooon@gmail.com>
Subject: [PATCH 14/14] mm: oom_kill: use IS_ERR() instead of strict checking
Date: Sun,  5 Sep 2010 22:33:12 +0400
Message-Id: <1283711592-7669-1-git-send-email-segooon@gmail.com>
Sender: owner-linux-mm@kvack.org
To: kernel-janitors@vger.kernel.org
Cc: Vasiliy Kulikov <segooon@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

From: Vasiliy Kulikov <segooon@gmail.com>

Use IS_ERR() instead of strict checking.

Signed-off-by: Vasiliy Kulikov <segooon@gmail.com>
---
 Compile tested.

 mm/oom_kill.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index fc81cb2..2ee3350 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -514,7 +514,7 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
 	read_lock(&tasklist_lock);
 retry:
 	p = select_bad_process(&points, limit, mem, NULL);
-	if (!p || PTR_ERR(p) == -1UL)
+	if (IS_ERR_OR_NULL(p))
 		goto out;
 
 	if (oom_kill_process(p, gfp_mask, 0, points, limit, mem, NULL,
@@ -691,7 +691,7 @@ retry:
 	p = select_bad_process(&points, totalpages, NULL,
 			constraint == CONSTRAINT_MEMORY_POLICY ? nodemask :
 								 NULL);
-	if (PTR_ERR(p) == -1UL)
+	if (IS_ERR(p))
 		goto out;
 
 	/* Found nothing?!?! Either we hang forever, or we panic. */
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
