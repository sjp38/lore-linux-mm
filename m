Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 7763A6B00EF
	for <linux-mm@kvack.org>; Thu, 17 May 2012 11:50:11 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so4013916pbb.14
        for <linux-mm@kvack.org>; Thu, 17 May 2012 08:50:10 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 2/4] slub: change cmpxchg_double_slab in unfreeze_partials to __cmpxchg_double_slab
Date: Fri, 18 May 2012 00:47:46 +0900
Message-Id: <1337269668-4619-3-git-send-email-js1304@gmail.com>
In-Reply-To: <1337269668-4619-1-git-send-email-js1304@gmail.com>
References: <1337269668-4619-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

unfreeze_partials() is only called with interrupt disabled,
so __cmpxchg_double_slab is suitable.

Signed-off-by: Joonsoo Kim <js1304@gmail.com>

diff --git a/mm/slub.c b/mm/slub.c
index d28bc45..c38efce 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1935,7 +1935,7 @@ static void unfreeze_partials(struct kmem_cache *s)
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
