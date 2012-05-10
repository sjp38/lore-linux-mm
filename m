Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 5D0C96B0044
	for <linux-mm@kvack.org>; Thu, 10 May 2012 12:02:23 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so2842504pbb.14
        for <linux-mm@kvack.org>; Thu, 10 May 2012 09:02:23 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH] slub: change cmpxchg_double_slab in unfreeze_partials to __cmpxchg_double_slab
Date: Fri, 11 May 2012 01:01:08 +0900
Message-Id: <1336665668-16340-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

unfreeze_partials() is only called with interrupt disabled,
so __cmpxchg_double_slab is suitable.

Signed-off-by: Joonsoo Kim <js1304@gmail.com>

diff --git a/mm/slub.c b/mm/slub.c
index addfb85..4cb895d8 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1932,7 +1932,7 @@ static void unfreeze_partials(struct kmem_cache *s)
 				l = m;
 			}
 
-		} while (!cmpxchg_double_slab(s, page,
+		} while (!__cmpxchg_double_slab(s, page,
 				old.freelist, old.counters,
 				new.freelist, new.counters,
 				"unfreezing slab"));
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
