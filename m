Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 15CD36B00F1
	for <linux-mm@kvack.org>; Thu, 17 May 2012 11:50:15 -0400 (EDT)
Received: by mail-pz0-f41.google.com with SMTP id p5so3846917dak.14
        for <linux-mm@kvack.org>; Thu, 17 May 2012 08:50:14 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 3/4] slub: use __SetPageSlab function to set PG_slab flag
Date: Fri, 18 May 2012 00:47:47 +0900
Message-Id: <1337269668-4619-4-git-send-email-js1304@gmail.com>
In-Reply-To: <1337269668-4619-1-git-send-email-js1304@gmail.com>
References: <1337269668-4619-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

To set page-flag, using SetPageXXXX() and __SetPageXXXX() is more
understandable and maintainable. So change it.

Signed-off-by: Joonsoo Kim <js1304@gmail.com>

diff --git a/mm/slub.c b/mm/slub.c
index c38efce..69342fd 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1369,7 +1369,7 @@ static struct page *new_slab(struct kmem_cache *s, gfp_t flags, int node)
 
 	inc_slabs_node(s, page_to_nid(page), page->objects);
 	page->slab = s;
-	page->flags |= 1 << PG_slab;
+	__SetPageSlab(page);
 
 	start = page_address(page);
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
