Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id DEBEA6B0257
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 01:45:14 -0500 (EST)
Received: by mail-ig0-f176.google.com with SMTP id to4so51832710igc.0
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 22:45:14 -0800 (PST)
Received: from mail-ig0-x22b.google.com (mail-ig0-x22b.google.com. [2607:f8b0:4001:c05::22b])
        by mx.google.com with ESMTPS id e63si10450951iod.102.2015.12.15.22.45.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Dec 2015 22:45:14 -0800 (PST)
Received: by mail-ig0-x22b.google.com with SMTP id xm8so35849380igb.1
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 22:45:14 -0800 (PST)
From: Jiading Gai <jiading.gai@gmail.com>
Subject: [PATCH] mm: memcontrol: fixed three spelling errors.
Date: Wed, 16 Dec 2015 01:45:05 -0500
Message-Id: <1450248305-7971-1-git-send-email-jiading.gai@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Jiading Gai <paul.paul.mit@gmail.com>, Jiading Gai <jiading.gai@gmail.com>

From: Jiading Gai <paul.paul.mit@gmail.com>

Fixed three spelling errors.

Signed-off-by: Jiading Gai <jiading.gai@gmail.com>
---
 mm/memcontrol.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index e234c21..4e424fc 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1744,7 +1744,7 @@ bool mem_cgroup_oom_synchronize(bool handle)
 		/*
 		 * There is no guarantee that an OOM-lock contender
 		 * sees the wakeups triggered by the OOM kill
-		 * uncharges.  Wake any sleepers explicitely.
+		 * uncharges.  Wake any sleepers explicitly.
 		 */
 		memcg_oom_recover(memcg);
 	}
@@ -4277,7 +4277,7 @@ mem_cgroup_css_online(struct cgroup_subsys_state *css)
 		page_counter_init(&memcg->memsw, NULL);
 		page_counter_init(&memcg->kmem, NULL);
 		/*
-		 * Deeper hierachy with use_hierarchy == false doesn't make
+		 * Deeper hierarchy with use_hierarchy == false doesn't make
 		 * much sense so let cgroup subsystem know about this
 		 * unfortunate state in our controller.
 		 */
@@ -4809,7 +4809,7 @@ static int mem_cgroup_can_attach(struct cgroup_taskset *tset)
 		return 0;
 
 	/*
-	 * We are now commited to this value whatever it is. Changes in this
+	 * We are now committed to this value whatever it is. Changes in this
 	 * tunable will only affect upcoming migrations, not the current one.
 	 * So we need to save it, and keep it going.
 	 */
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
