Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1E7756B0253
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 21:57:14 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so38042099pac.3
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 18:57:13 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id sc6si9277174pac.7.2015.10.13.18.57.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Oct 2015 18:57:13 -0700 (PDT)
Received: by padcn9 with SMTP id cn9so7049700pad.2
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 18:57:13 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: [PATCH] zsmalloc: don't test shrinker_enabled in zs_shrinker_count()
Date: Wed, 14 Oct 2015 10:57:59 +0900
Message-Id: <1444787879-5428-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

We don't let user to disable shrinker in zsmalloc (once
it's been enabled), so no need to check ->shrinker_enabled
in zs_shrinker_count(), at the moment at least.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 mm/zsmalloc.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 7ad5e54..8ba247d 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1822,9 +1822,6 @@ static unsigned long zs_shrinker_count(struct shrinker *shrinker,
 	struct zs_pool *pool = container_of(shrinker, struct zs_pool,
 			shrinker);
 
-	if (!pool->shrinker_enabled)
-		return 0;
-
 	for (i = zs_size_classes - 1; i >= 0; i--) {
 		class = pool->size_class[i];
 		if (!class)
-- 
2.6.1.134.g4b1fd35

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
