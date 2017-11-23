Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 64F756B0287
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 17:17:28 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id y42so12393314wrd.23
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 14:17:28 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n23sor7261095wra.8.2017.11.23.14.17.27
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Nov 2017 14:17:27 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 20/23] slub: make slab_index() return unsigned int
Date: Fri, 24 Nov 2017 01:16:25 +0300
Message-Id: <20171123221628.8313-20-adobriyan@gmail.com>
In-Reply-To: <20171123221628.8313-1-adobriyan@gmail.com>
References: <20171123221628.8313-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, Alexey Dobriyan <adobriyan@gmail.com>

slab_index() returns index of an object within a slab
which is at most u15 (or u16?).

Iterators additionally guarantee that "p >= addr".

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 mm/slub.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index ce71665e266c..04c8348b8ce9 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -311,7 +311,7 @@ static inline void set_freepointer(struct kmem_cache *s, void *object, void *fp)
 		__p += (__s)->size, __idx++)
 
 /* Determine object index from a given position */
-static inline int slab_index(void *p, struct kmem_cache *s, void *addr)
+static inline unsigned int slab_index(void *p, struct kmem_cache *s, void *addr)
 {
 	return (p - addr) / s->size;
 }
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
