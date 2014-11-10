Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 471E26B012C
	for <linux-mm@kvack.org>; Mon, 10 Nov 2014 07:09:27 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id fa1so8142953pad.39
        for <linux-mm@kvack.org>; Mon, 10 Nov 2014 04:09:27 -0800 (PST)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id hn8si16244807pac.212.2014.11.10.04.09.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 10 Nov 2014 04:09:25 -0800 (PST)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NET00KOAOKFX4A0@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 10 Nov 2014 12:12:15 +0000 (GMT)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH 1/3] mm: sl[aou]b: introduce kmem_cache_zalloc_node()
Date: Mon, 10 Nov 2014 15:06:56 +0300
Message-id: <1415621218-6438-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, Andrey Ryabinin <a.ryabinin@samsung.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

kmem_cache_zalloc_node() allocates zeroed memory for a particular
cache from a specified memory node. To be used for struct irq_desc.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 include/linux/slab.h | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index c265bec..b3248fa 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -574,6 +574,12 @@ static inline void *kmem_cache_zalloc(struct kmem_cache *k, gfp_t flags)
 	return kmem_cache_alloc(k, flags | __GFP_ZERO);
 }
 
+static inline void *kmem_cache_zalloc_node(struct kmem_cache *k, gfp_t flags,
+					int node)
+{
+	return kmem_cache_alloc_node(k, flags | __GFP_ZERO, node);
+}
+
 /**
  * kzalloc - allocate memory. The memory is set to zero.
  * @size: how many bytes of memory are required.
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
