Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 70A7F6B0031
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 01:00:00 -0500 (EST)
Received: by mail-wg0-f53.google.com with SMTP id b13so10175327wgh.20
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 21:59:59 -0800 (PST)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id l3si291607wiz.30.2013.11.20.21.59.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 20 Nov 2013 21:59:59 -0800 (PST)
Message-ID: <528DA0C0.8010505@huawei.com>
Date: Thu, 21 Nov 2013 13:57:20 +0800
From: Qiang Huang <h.huangqiang@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] slab: remove the redundant declaration of kmalloc
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


Signed-off-by: Qiang Huang <h.huangqiang@huawei.com>
---
 include/linux/slab.h | 102 +++++++++++++++++++++++----------------------------
 1 file changed, 46 insertions(+), 56 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index 74f1058..630f22f 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -381,7 +381,52 @@ static __always_inline void *kmalloc_large(size_t size, gfp_t flags)
 /**
  * kmalloc - allocate memory
  * @size: how many bytes of memory are required.
- * @flags: the type of memory to allocate (see kcalloc).
+ * @flags: the type of memory to allocate.
+ *
+ * The @flags argument may be one of:
+ *
+ * %GFP_USER - Allocate memory on behalf of user.  May sleep.
+ *
+ * %GFP_KERNEL - Allocate normal kernel ram.  May sleep.
+ *
+ * %GFP_ATOMIC - Allocation will not sleep.  May use emergency pools.
+ *   For example, use this inside interrupt handlers.
+ *
+ * %GFP_HIGHUSER - Allocate pages from high memory.
+ *
+ * %GFP_NOIO - Do not do any I/O at all while trying to get memory.
+ *
+ * %GFP_NOFS - Do not make any fs calls while trying to get memory.
+ *
+ * %GFP_NOWAIT - Allocation will not sleep.
+ *
+ * %GFP_THISNODE - Allocate node-local memory only.
+ *
+ * %GFP_DMA - Allocation suitable for DMA.
+ *   Should only be used for kmalloc() caches. Otherwise, use a
+ *   slab created with SLAB_DMA.
+ *
+ * Also it is possible to set different flags by OR'ing
+ * in one or more of the following additional @flags:
+ *
+ * %__GFP_COLD - Request cache-cold pages instead of
+ *   trying to return cache-warm pages.
+ *
+ * %__GFP_HIGH - This allocation has high priority and may use emergency pools.
+ *
+ * %__GFP_NOFAIL - Indicate that this allocation is in no way allowed to fail
+ *   (think twice before using).
+ *
+ * %__GFP_NORETRY - If memory is not immediately available,
+ *   then give up at once.
+ *
+ * %__GFP_NOWARN - If allocation fails, don't issue any warnings.
+ *
+ * %__GFP_REPEAT - If allocation fails initially, try once more before failing.
+ *
+ * There are other flags available as well, but these are not intended
+ * for general use, and so are not documented here. For a full list of
+ * potential flags, always refer to linux/gfp.h.
  *
  * kmalloc is the normal method of allocating memory
  * for objects smaller than page size in the kernel.
@@ -495,61 +540,6 @@ int cache_show(struct kmem_cache *s, struct seq_file *m);
 void print_slabinfo_header(struct seq_file *m);

 /**
- * kmalloc - allocate memory
- * @size: how many bytes of memory are required.
- * @flags: the type of memory to allocate.
- *
- * The @flags argument may be one of:
- *
- * %GFP_USER - Allocate memory on behalf of user.  May sleep.
- *
- * %GFP_KERNEL - Allocate normal kernel ram.  May sleep.
- *
- * %GFP_ATOMIC - Allocation will not sleep.  May use emergency pools.
- *   For example, use this inside interrupt handlers.
- *
- * %GFP_HIGHUSER - Allocate pages from high memory.
- *
- * %GFP_NOIO - Do not do any I/O at all while trying to get memory.
- *
- * %GFP_NOFS - Do not make any fs calls while trying to get memory.
- *
- * %GFP_NOWAIT - Allocation will not sleep.
- *
- * %GFP_THISNODE - Allocate node-local memory only.
- *
- * %GFP_DMA - Allocation suitable for DMA.
- *   Should only be used for kmalloc() caches. Otherwise, use a
- *   slab created with SLAB_DMA.
- *
- * Also it is possible to set different flags by OR'ing
- * in one or more of the following additional @flags:
- *
- * %__GFP_COLD - Request cache-cold pages instead of
- *   trying to return cache-warm pages.
- *
- * %__GFP_HIGH - This allocation has high priority and may use emergency pools.
- *
- * %__GFP_NOFAIL - Indicate that this allocation is in no way allowed to fail
- *   (think twice before using).
- *
- * %__GFP_NORETRY - If memory is not immediately available,
- *   then give up at once.
- *
- * %__GFP_NOWARN - If allocation fails, don't issue any warnings.
- *
- * %__GFP_REPEAT - If allocation fails initially, try once more before failing.
- *
- * There are other flags available as well, but these are not intended
- * for general use, and so are not documented here. For a full list of
- * potential flags, always refer to linux/gfp.h.
- *
- * kmalloc is the normal method of allocating memory
- * in the kernel.
- */
-static __always_inline void *kmalloc(size_t size, gfp_t flags);
-
-/**
  * kmalloc_array - allocate memory for an array.
  * @n: number of elements.
  * @size: element size.
-- 
1.8.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
