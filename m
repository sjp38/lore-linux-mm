Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 5BB59900015
	for <linux-mm@kvack.org>; Wed, 22 Apr 2015 02:23:51 -0400 (EDT)
Received: by widdi4 with SMTP id di4so164788474wid.0
        for <linux-mm@kvack.org>; Tue, 21 Apr 2015 23:23:50 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id ea1si25754701wib.2.2015.04.21.23.23.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 21 Apr 2015 23:23:49 -0700 (PDT)
From: Wang Long <long.wanglong@huawei.com>
Subject: [PATCH] kasan: Remove duplicate definition of the macro KASAN_FREE_PAGE
Date: Wed, 22 Apr 2015 06:23:32 +0000
Message-ID: <1429683812-2416-1-git-send-email-long.wanglong@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: a.ryabinin@samsung.com, adech.fo@gmail.com, mmarek@suse.cz
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, peifeiyue@huawei.com

This patch just remove duplicate definition of the macro
KASAN_FREE_PAGE in mm/kasan/kasan.h

Signed-off-by: Wang Long <long.wanglong@huawei.com>
---
 mm/kasan/kasan.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index 4986b0a..c242adf 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -7,7 +7,6 @@
 #define KASAN_SHADOW_MASK       (KASAN_SHADOW_SCALE_SIZE - 1)
 
 #define KASAN_FREE_PAGE         0xFF  /* page was freed */
-#define KASAN_FREE_PAGE         0xFF  /* page was freed */
 #define KASAN_PAGE_REDZONE      0xFE  /* redzone for kmalloc_large allocations */
 #define KASAN_KMALLOC_REDZONE   0xFC  /* redzone inside slub object */
 #define KASAN_KMALLOC_FREE      0xFB  /* object was freed (kmem_cache_free/kfree) */
-- 
1.8.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
