Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id BB95B6B0044
	for <linux-mm@kvack.org>; Thu, 10 May 2012 11:57:37 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so2835046pbb.14
        for <linux-mm@kvack.org>; Thu, 10 May 2012 08:57:36 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH] slub: change cmpxchg_double_slab in get_freelist() to __cmpxchg_double_slab
Date: Fri, 11 May 2012 00:56:18 +0900
Message-Id: <1336665378-2967-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

get_freelist() is only called by __slab_alloc with interrupt disabled,
so __cmpxchg_double_slab is suitable.

Signed-off-by: Joonsoo Kim <js1304@gmail.com>

diff --git a/mm/slub.c b/mm/slub.c
index 323778e..addfb85 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2176,7 +2176,7 @@ static inline void *get_freelist(struct kmem_cache *s, struct page *page)
 		new.inuse = page->objects;
 		new.frozen = freelist != NULL;
 
-	} while (!cmpxchg_double_slab(s, page,
+	} while (!__cmpxchg_double_slab(s, page,
 		freelist, counters,
 		NULL, new.counters,
 		"get_freelist"));
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
