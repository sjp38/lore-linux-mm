Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 51D7B6B002C
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 15:08:15 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id f16so11996660wre.0
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 12:08:15 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y30sor6258935wrb.45.2018.03.05.12.08.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 12:08:14 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 22/25] slub: make slab_index() return unsigned int
Date: Mon,  5 Mar 2018 23:07:27 +0300
Message-Id: <20180305200730.15812-22-adobriyan@gmail.com>
In-Reply-To: <20180305200730.15812-1-adobriyan@gmail.com>
References: <20180305200730.15812-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, adobriyan@gmail.com

slab_index() returns index of an object within a slab
which is at most u15 (or u16?).

Iterators additionally guarantee that "p >= addr".

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 mm/slub.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index 865d964f4c93..5d367e0a64ca 100644
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
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
