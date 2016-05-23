Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4191B6B0005
	for <linux-mm@kvack.org>; Mon, 23 May 2016 12:28:51 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id m124so25180198itg.0
        for <linux-mm@kvack.org>; Mon, 23 May 2016 09:28:51 -0700 (PDT)
Received: from emea01-am1-obe.outbound.protection.outlook.com (mail-am1on0114.outbound.protection.outlook.com. [157.56.112.114])
        by mx.google.com with ESMTPS id k21si11244206otb.176.2016.05.23.09.28.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 23 May 2016 09:28:50 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH] mm: slub: remove unused virt_to_obj()
Date: Mon, 23 May 2016 19:29:21 +0300
Message-ID: <1464020961-2242-1-git-send-email-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrey Ryabinin <aryabinin@virtuozzo.com>

It's unused since commit 7ed2f9e66385 ("mm, kasan: SLAB support")

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 include/linux/slub_def.h | 16 ----------------
 1 file changed, 16 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 665cd0c..d1faa01 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -111,22 +111,6 @@ static inline void sysfs_slab_remove(struct kmem_cache *s)
 }
 #endif
 
-
-/**
- * virt_to_obj - returns address of the beginning of object.
- * @s: object's kmem_cache
- * @slab_page: address of slab page
- * @x: address within object memory range
- *
- * Returns address of the beginning of object
- */
-static inline void *virt_to_obj(struct kmem_cache *s,
-				const void *slab_page,
-				const void *x)
-{
-	return (void *)x - ((x - slab_page) % s->size);
-}
-
 void object_err(struct kmem_cache *s, struct page *page,
 		u8 *object, char *reason);
 
-- 
2.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
