Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 1903F6B0062
	for <linux-mm@kvack.org>; Wed,  7 May 2014 02:04:42 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id ey11so688463pad.18
        for <linux-mm@kvack.org>; Tue, 06 May 2014 23:04:41 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id hp1si13230065pad.139.2014.05.06.23.04.39
        for <linux-mm@kvack.org>;
        Tue, 06 May 2014 23:04:40 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 10/10] slab: remove BAD_ALIEN_MAGIC
Date: Wed,  7 May 2014 15:06:20 +0900
Message-Id: <1399442780-28748-11-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1399442780-28748-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1399442780-28748-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

BAD_ALIEN_MAGIC value isn't used anymore. So remove it.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

diff --git a/mm/slab.c b/mm/slab.c
index 4030a89..8476ffc 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -437,8 +437,6 @@ static struct kmem_cache kmem_cache_boot = {
 	.name = "kmem_cache",
 };
 
-#define BAD_ALIEN_MAGIC 0x01020304ul
-
 static DEFINE_PER_CPU(struct delayed_work, slab_reap_work);
 
 static inline struct array_cache *cpu_cache_get(struct kmem_cache *cachep)
@@ -783,7 +781,7 @@ static int transfer_objects(struct array_cache *to,
 static inline struct alien_cache **alloc_alien_cache(int node,
 						int limit, gfp_t gfp)
 {
-	return (struct alien_cache **)BAD_ALIEN_MAGIC;
+	return NULL;
 }
 
 static inline void free_alien_cache(struct alien_cache **ac_ptr)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
