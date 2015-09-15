Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 662BF6B0038
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 14:28:19 -0400 (EDT)
Received: by lagj9 with SMTP id j9so115284808lag.2
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 11:28:18 -0700 (PDT)
Received: from mail-la0-f47.google.com (mail-la0-f47.google.com. [209.85.215.47])
        by mx.google.com with ESMTPS id rz7si15259322lbb.129.2015.09.15.11.28.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Sep 2015 11:28:18 -0700 (PDT)
Received: by lamp12 with SMTP id p12so112310565lam.0
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 11:28:17 -0700 (PDT)
From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [PATCH] mm: slab: convert slab_is_available to boolean
Date: Tue, 15 Sep 2015 20:50:01 +0300
Message-Id: <1442339401-4145-1-git-send-email-kda@linux-powerpc.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Denis Kirjanov <kda@linux-powerpc.org>

A good one candidate to return a boolean result

Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
---
 include/linux/slab.h | 2 +-
 mm/slab_common.c     | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 7e37d44..7c82e3b 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -111,7 +111,7 @@ struct mem_cgroup;
  * struct kmem_cache related prototypes
  */
 void __init kmem_cache_init(void);
-int slab_is_available(void);
+bool slab_is_available(void);
 
 struct kmem_cache *kmem_cache_create(const char *, size_t, size_t,
 			unsigned long,
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 5ce4fae..113a6fd 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -692,7 +692,7 @@ int kmem_cache_shrink(struct kmem_cache *cachep)
 }
 EXPORT_SYMBOL(kmem_cache_shrink);
 
-int slab_is_available(void)
+bool slab_is_available(void)
 {
 	return slab_state >= UP;
 }
-- 
2.4.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
