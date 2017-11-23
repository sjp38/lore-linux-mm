Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4416B6B028D
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 17:17:31 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id f9so12756140wra.2
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 14:17:31 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e4sor1867706wrc.14.2017.11.23.14.17.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Nov 2017 14:17:30 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 23/23] slab: use 32-bit arithmetic in freelist_randomize()
Date: Fri, 24 Nov 2017 01:16:28 +0300
Message-Id: <20171123221628.8313-23-adobriyan@gmail.com>
In-Reply-To: <20171123221628.8313-1-adobriyan@gmail.com>
References: <20171123221628.8313-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, Alexey Dobriyan <adobriyan@gmail.com>

SLAB doesn't support 4GB+ of objects per slab, so randomization doesn't
need size_t.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 mm/slab_common.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 2b5435e1e619..012f0af5cd81 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1140,10 +1140,10 @@ EXPORT_SYMBOL(kmalloc_order_trace);
 #ifdef CONFIG_SLAB_FREELIST_RANDOM
 /* Randomize a generic freelist */
 static void freelist_randomize(struct rnd_state *state, unsigned int *list,
-			size_t count)
+			       unsigned int count)
 {
-	size_t i;
 	unsigned int rand;
+	unsigned int i;
 
 	for (i = 0; i < count; i++)
 		list[i] = i;
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
