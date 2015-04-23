Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1A70F6B0032
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 06:05:18 -0400 (EDT)
Received: by layy10 with SMTP id y10so9060232lay.0
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 03:05:17 -0700 (PDT)
Received: from mail-la0-x22b.google.com (mail-la0-x22b.google.com. [2a00:1450:4010:c03::22b])
        by mx.google.com with ESMTPS id lk7si5652066lac.61.2015.04.23.03.05.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Apr 2015 03:05:16 -0700 (PDT)
Received: by lagv1 with SMTP id v1so8976632lag.3
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 03:05:15 -0700 (PDT)
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Subject: [PATCH] linux/slab.h: fix three off-by-one typos in comment
Date: Thu, 23 Apr 2015 12:04:43 +0200
Message-Id: <1429783484-29690-1-git-send-email-linux@rasmusvillemoes.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rasmus Villemoes <linux@rasmusvillemoes.dk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The first is a keyboard-off-by-one, the other two the ordinary mathy
kind.

Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
---
 include/linux/slab.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index ffd24c830151..a99f0e5243e1 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -240,8 +240,8 @@ extern struct kmem_cache *kmalloc_dma_caches[KMALLOC_SHIFT_HIGH + 1];
  * belongs to.
  * 0 = zero alloc
  * 1 =  65 .. 96 bytes
- * 2 = 120 .. 192 bytes
- * n = 2^(n-1) .. 2^n -1
+ * 2 = 129 .. 192 bytes
+ * n = 2^(n-1)+1 .. 2^n
  */
 static __always_inline int kmalloc_index(size_t size)
 {
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
