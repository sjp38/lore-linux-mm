Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 9FC5F4403D9
	for <linux-mm@kvack.org>; Tue, 12 Jan 2016 10:16:40 -0500 (EST)
Received: by mail-qg0-f50.google.com with SMTP id e32so341724657qgf.3
        for <linux-mm@kvack.org>; Tue, 12 Jan 2016 07:16:40 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c191si116804171qhc.74.2016.01.12.07.16.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jan 2016 07:16:40 -0800 (PST)
Subject: [PATCH V2 11/11] mm: fix some spelling
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 12 Jan 2016 16:16:37 +0100
Message-ID: <20160112151631.31725.45290.stgit@firesoul>
In-Reply-To: <20160112151257.31725.71327.stgit@firesoul>
References: <20160112151257.31725.71327.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>

Fixup trivial spelling errors, noticed while reading the code.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 include/linux/memcontrol.h |    2 +-
 include/linux/slab.h       |    2 +-
 mm/slab.h                  |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index cd0e2413c358..e88c57e83215 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -757,7 +757,7 @@ int __memcg_kmem_charge(struct page *page, gfp_t gfp, int order);
 void __memcg_kmem_uncharge(struct page *page, int order);
 
 /*
- * helper for acessing a memcg's index. It will be used as an index in the
+ * helper for accessing a memcg's index. It will be used as an index in the
  * child cache array in kmem_cache, and also to derive its name. This function
  * will return -1 when this is not a kmem-limited memcg.
  */
diff --git a/include/linux/slab.h b/include/linux/slab.h
index df70e69c8f7f..5bbde0814235 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -309,7 +309,7 @@ void *kmem_cache_alloc(struct kmem_cache *, gfp_t flags) __assume_slab_alignment
 void kmem_cache_free(struct kmem_cache *, void *);
 
 /*
- * Bulk allocation and freeing operations. These are accellerated in an
+ * Bulk allocation and freeing operations. These are accelerated in an
  * allocator specific way to avoid taking locks repeatedly or building
  * metadata structures unnecessarily.
  *
diff --git a/mm/slab.h b/mm/slab.h
index 343ee496c53b..3357430e29e8 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -170,7 +170,7 @@ ssize_t slabinfo_write(struct file *file, const char __user *buffer,
 /*
  * Generic implementation of bulk operations
  * These are useful for situations in which the allocator cannot
- * perform optimizations. In that case segments of the objecct listed
+ * perform optimizations. In that case segments of the object listed
  * may be allocated or freed using these operations.
  */
 void __kmem_cache_free_bulk(struct kmem_cache *, size_t, void **);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
