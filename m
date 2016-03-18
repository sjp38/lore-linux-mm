Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id A1459828DF
	for <linux-mm@kvack.org>; Fri, 18 Mar 2016 17:26:17 -0400 (EDT)
Received: by mail-wm0-f54.google.com with SMTP id l68so85289345wml.0
        for <linux-mm@kvack.org>; Fri, 18 Mar 2016 14:26:17 -0700 (PDT)
Received: from Galois.linutronix.de (linutronix.de. [2001:470:1f0b:db:abcd:42:0:1])
        by mx.google.com with ESMTPS id y3si18127923wjy.136.2016.03.18.14.26.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Fri, 18 Mar 2016 14:26:16 -0700 (PDT)
From: Richard Cochran <rcochran@linutronix.de>
Subject: [PATCH 1/5] mm: memcontrol: Remove redundant hot plug notifier test.
Date: Fri, 18 Mar 2016 22:26:07 +0100
Message-Id: <1458336371-17748-1-git-send-email-rcochran@linutronix.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: rt@linutronix.de, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, cgroups@vger.kernel.org, linux-mm@kvack.org

The test for ONLINE is redundant because the following test for !DEAD
already includes the online case.  This patch removes the superfluous
code.

Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: cgroups@vger.kernel.org
Cc: linux-mm@kvack.org
Signed-off-by: Richard Cochran <rcochran@linutronix.de>
---
 mm/memcontrol.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index d06cae2..993a261 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1916,9 +1916,6 @@ static int memcg_cpu_hotplug_callback(struct notifier_block *nb,
 	int cpu = (unsigned long)hcpu;
 	struct memcg_stock_pcp *stock;
 
-	if (action == CPU_ONLINE)
-		return NOTIFY_OK;
-
 	if (action != CPU_DEAD && action != CPU_DEAD_FROZEN)
 		return NOTIFY_OK;
 
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
