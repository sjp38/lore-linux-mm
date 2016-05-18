Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C30F66B0260
	for <linux-mm@kvack.org>; Wed, 18 May 2016 03:24:27 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 77so79536731pfz.3
        for <linux-mm@kvack.org>; Wed, 18 May 2016 00:24:27 -0700 (PDT)
Received: from mail.windriver.com (mail.windriver.com. [147.11.1.11])
        by mx.google.com with ESMTPS id td3si10430827pac.24.2016.05.18.00.24.25
        for <linux-mm@kvack.org>
        (version=TLS1_1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 18 May 2016 00:24:25 -0700 (PDT)
From: roy.qing.li@gmail.com
Subject: [PATCH] mm: memcontrol: fix the return in mem_cgroup_margin
Date: Wed, 18 May 2016 15:24:15 +0800
Message-Id: <1463556255-31892-1-git-send-email-roy.qing.li@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cgroups@vger.kernel.org, linux-mm@kvack.org
Cc: hannes@cmpxchg.org, mhocko@kernel.org, vdavydov@virtuozzo.com

From: Li RongQing <roy.qing.li@gmail.com>

when memory+swap is over limit, return 0

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 mm/memcontrol.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index fe787f5..e9211c2 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1090,6 +1090,8 @@ static unsigned long mem_cgroup_margin(struct mem_cgroup *memcg)
 		limit = READ_ONCE(memcg->memsw.limit);
 		if (count <= limit)
 			margin = min(margin, limit - count);
+		else
+			margin = 0;
 	}
 
 	return margin;
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
