Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2A6F36B0253
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 10:28:00 -0400 (EDT)
Received: by pacan13 with SMTP id an13so6745895pac.1
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 07:27:59 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id zr6si9869721pac.3.2015.07.29.07.27.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jul 2015 07:27:59 -0700 (PDT)
Received: by padck2 with SMTP id ck2so6663234pad.0
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 07:27:59 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [PATCH] zsmalloc: remove null check from destroy_handle_cache()
Date: Wed, 29 Jul 2015 23:26:58 +0900
Message-Id: <1438180018-11773-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

We can pass a NULL cache pointer to kmem_cache_destroy(),
because it NULL-checks its argument now. Remove redundant
test from destroy_handle_cache().

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 mm/zsmalloc.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 09aedd9..f135b1b 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -288,8 +288,7 @@ static int create_handle_cache(struct zs_pool *pool)
 
 static void destroy_handle_cache(struct zs_pool *pool)
 {
-	if (pool->handle_cachep)
-		kmem_cache_destroy(pool->handle_cachep);
+	kmem_cache_destroy(pool->handle_cachep);
 }
 
 static unsigned long alloc_handle(struct zs_pool *pool)
-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
