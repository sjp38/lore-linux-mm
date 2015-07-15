Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 602842802C4
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 19:42:45 -0400 (EDT)
Received: by pdjr16 with SMTP id r16so33188354pdj.3
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 16:42:45 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id i3si1134250pdp.75.2015.07.15.16.42.43
        for <linux-mm@kvack.org>;
        Wed, 15 Jul 2015 16:42:44 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] zsmalloc: use class->pages_per_zspage
Date: Thu, 16 Jul 2015 08:42:44 +0900
Message-Id: <1437003764-2968-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

There is no need to recalcurate pages_per_zspage in runtime.
Just use class->pages_per_zspage to avoid unnecessary runtime
overhead.

Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/zsmalloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 27b9661c8fa6..154a30e9c8a8 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1711,7 +1711,7 @@ static unsigned long zs_can_compact(struct size_class *class)
 	obj_wasted /= get_maxobj_per_zspage(class->size,
 			class->pages_per_zspage);
 
-	return obj_wasted * get_pages_per_zspage(class->size);
+	return obj_wasted * class->pages_per_zspage;
 }
 
 static void __zs_compact(struct zs_pool *pool, struct size_class *class)
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
