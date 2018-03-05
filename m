Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id AC09E6B002E
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 15:08:17 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id 96so9434312wrk.12
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 12:08:17 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z37sor6298055wrb.52.2018.03.05.12.08.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 12:08:16 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 24/25] slub: make size_from_object() return unsigned int
Date: Mon,  5 Mar 2018 23:07:29 +0300
Message-Id: <20180305200730.15812-24-adobriyan@gmail.com>
In-Reply-To: <20180305200730.15812-1-adobriyan@gmail.com>
References: <20180305200730.15812-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, adobriyan@gmail.com

Function returns size of the object without red zone which can't be negative.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 mm/slub.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index 9df658ee83fe..7f27fb3b13b7 100644
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
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
