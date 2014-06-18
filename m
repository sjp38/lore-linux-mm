Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id A64966B0031
	for <linux-mm@kvack.org>; Wed, 18 Jun 2014 10:17:44 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id lf10so792457pab.30
        for <linux-mm@kvack.org>; Wed, 18 Jun 2014 07:17:44 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id ce7si2378023pad.113.2014.06.18.07.17.43
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 18 Jun 2014 07:17:43 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N7D004SOBPGGS40@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 18 Jun 2014 15:17:40 +0100 (BST)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH] mm: slab.h: wrap the whole file with guarding macro
Date: Wed, 18 Jun 2014 18:11:35 +0400
Message-id: <1403100695-1350-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrey Ryabinin <a.ryabinin@samsung.com>

Guarding section:
	#ifndef MM_SLAB_H
	#define MM_SLAB_H
	...
	#endif
currently doesn't cover the whole mm/slab.h. It seems like it was
done unintentionally.

Wrap the whole file by moving closing #endif to the end of it.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 mm/slab.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/slab.h b/mm/slab.h
index 961a3fb..90954f5e 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -260,8 +260,6 @@ static inline struct kmem_cache *cache_from_obj(struct kmem_cache *s, void *x)
 	WARN_ON_ONCE(1);
 	return s;
 }
-#endif
-
 
 /*
  * The slab lists for all objects.
@@ -296,3 +294,5 @@ struct kmem_cache_node {
 
 void *slab_next(struct seq_file *m, void *p, loff_t *pos);
 void slab_stop(struct seq_file *m, void *p);
+
+#endif /* MM_SLAB_H */
-- 
1.8.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
