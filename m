Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A04D66B002F
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 15:08:18 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id p14so4227479wmc.0
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 12:08:18 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f15sor6365727wrh.67.2018.03.05.12.08.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 12:08:17 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 25/25] slab: use 32-bit arithmetic in freelist_randomize()
Date: Mon,  5 Mar 2018 23:07:30 +0300
Message-Id: <20180305200730.15812-25-adobriyan@gmail.com>
In-Reply-To: <20180305200730.15812-1-adobriyan@gmail.com>
References: <20180305200730.15812-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, adobriyan@gmail.com

SLAB doesn't support 4GB+ of objects per slab, therefore randomization
doesn't need size_t.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 mm/slab_common.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 01224cb90080..e2e2485b3496 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1186,10 +1186,10 @@ EXPORT_SYMBOL(kmalloc_order_trace);
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
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
