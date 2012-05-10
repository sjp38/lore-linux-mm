Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id E6BB06B00F8
	for <linux-mm@kvack.org>; Thu, 10 May 2012 11:34:13 -0400 (EDT)
Received: by mail-pz0-f41.google.com with SMTP id p5so2565828dak.14
        for <linux-mm@kvack.org>; Thu, 10 May 2012 08:34:13 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH] slub: fix a possible memory leak
Date: Fri, 11 May 2012 00:32:59 +0900
Message-Id: <1336663979-2611-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

Memory allocated by kstrdup should be freed,
when kmalloc(kmem_size, GFP_KERNEL) is failed.

Signed-off-by: Joonsoo Kim <js1304@gmail.com>

diff --git a/mm/slub.c b/mm/slub.c
index 23d66aa..9c920a0 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3968,9 +3968,9 @@ struct kmem_cache *kmem_cache_create(const char *name, size_t size,
 			}
 			return s;
 		}
-		kfree(n);
 		kfree(s);
 	}
+	kfree(n);
 err:
 	up_write(&slub_lock);
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
