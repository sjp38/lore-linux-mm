Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com [209.85.218.54])
	by kanga.kvack.org (Postfix) with ESMTP id 402CC6B0038
	for <linux-mm@kvack.org>; Wed, 16 Sep 2015 08:12:05 -0400 (EDT)
Received: by oixx17 with SMTP id x17so123164931oix.0
        for <linux-mm@kvack.org>; Wed, 16 Sep 2015 05:12:05 -0700 (PDT)
Received: from m12-13.163.com (m12-13.163.com. [220.181.12.13])
        by mx.google.com with ESMTP id k10si12683531oel.57.2015.09.16.05.10.28
        for <linux-mm@kvack.org>;
        Wed, 16 Sep 2015 05:12:04 -0700 (PDT)
From: Yaowei Bai <bywxiaobai@163.com>
Subject: [PATCH 1/3] mm/vmscan: make inactive_anon_is_low_global return directly
Date: Wed, 16 Sep 2015 19:59:58 +0800
Message-Id: <1442404800-4051-1-git-send-email-bywxiaobai@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, mhocko@kernel.org, rientjes@google.com, hannes@cmpxchg.org, vdavydov@parallels.com, oleg@redhat.com, vbabka@suse.cz, iamjoonsoo.kim@lge.com, zhangyanfei@cn.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Delete unnecessary if to let inactive_anon_is_low_global return
directly.

No functional changes.

Signed-off-by: Yaowei Bai <bywxiaobai@163.com>
---
 mm/vmscan.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2d978b2..2785d8e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1866,10 +1866,7 @@ static int inactive_anon_is_low_global(struct zone *zone)
 	active = zone_page_state(zone, NR_ACTIVE_ANON);
 	inactive = zone_page_state(zone, NR_INACTIVE_ANON);
 
-	if (inactive * zone->inactive_ratio < active)
-		return 1;
-
-	return 0;
+	return inactive * zone->inactive_ratio < active;
 }
 
 /**
-- 
1.9.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
