Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5BA2F6B0289
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 17:17:30 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id q127so5606900wmd.1
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 14:17:30 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e8sor1938151wmf.30.2017.11.23.14.17.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Nov 2017 14:17:29 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 22/23] slub: make size_from_object() return unsigned int
Date: Fri, 24 Nov 2017 01:16:27 +0300
Message-Id: <20171123221628.8313-22-adobriyan@gmail.com>
In-Reply-To: <20171123221628.8313-1-adobriyan@gmail.com>
References: <20171123221628.8313-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, Alexey Dobriyan <adobriyan@gmail.com>

Function returns size of the object without red zone, so can't be negative.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 mm/slub.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index 27e619a38a02..5badbac9d650 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -466,7 +466,7 @@ static void get_map(struct kmem_cache *s, struct page *page, unsigned long *map)
 		set_bit(slab_index(p, s, addr), map);
 }
 
-static inline int size_from_object(struct kmem_cache *s)
+static inline unsigned int size_from_object(struct kmem_cache *s)
 {
 	if (s->flags & SLAB_RED_ZONE)
 		return s->size - s->red_left_pad;
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
