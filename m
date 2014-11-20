Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id AB2E36B0073
	for <linux-mm@kvack.org>; Thu, 20 Nov 2014 08:22:08 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id fb1so2566566pad.13
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 05:22:08 -0800 (PST)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id oi7si2985223pbb.169.2014.11.20.05.22.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 20 Nov 2014 05:22:07 -0800 (PST)
Received: by mail-pa0-f46.google.com with SMTP id lj1so2538730pab.5
        for <linux-mm@kvack.org>; Thu, 20 Nov 2014 05:22:06 -0800 (PST)
From: Mahendran Ganesh <opensource.ganesh@gmail.com>
Subject: [RFC PATCH] mm/zsmalloc: remove unnecessary check
Date: Thu, 20 Nov 2014 21:21:56 +0800
Message-Id: <1416489716-9967-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, iamjoonsoo.kim@lge.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mahendran Ganesh <opensource.ganesh@gmail.com>

ZS_SIZE_CLASSES is calc by:
  ((ZS_MAX_ALLOC_SIZE - ZS_MIN_ALLOC_SIZE) / ZS_SIZE_CLASS_DELTA + 1)

So when i is in [0, ZS_SIZE_CLASSES - 1), the size:
  size = ZS_MIN_ALLOC_SIZE + i * ZS_SIZE_CLASS_DELTA
will not be greater than ZS_MAX_ALLOC_SIZE

This patch removes the unnecessary check.

Signed-off-by: Mahendran Ganesh <opensource.ganesh@gmail.com>
---
 mm/zsmalloc.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index b3b57ef..f2279e2 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -973,8 +973,6 @@ struct zs_pool *zs_create_pool(gfp_t flags)
 		struct size_class *prev_class;
 
 		size = ZS_MIN_ALLOC_SIZE + i * ZS_SIZE_CLASS_DELTA;
-		if (size > ZS_MAX_ALLOC_SIZE)
-			size = ZS_MAX_ALLOC_SIZE;
 		pages_per_zspage = get_pages_per_zspage(size);
 
 		/*
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
