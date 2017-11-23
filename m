Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C14B46B0270
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 17:17:20 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id t92so12748055wrc.13
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 14:17:20 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f9sor1724525wmf.89.2017.11.23.14.17.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Nov 2017 14:17:19 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 12/23] slub: make ->align unsigned int
Date: Fri, 24 Nov 2017 01:16:17 +0300
Message-Id: <20171123221628.8313-12-adobriyan@gmail.com>
In-Reply-To: <20171123221628.8313-1-adobriyan@gmail.com>
References: <20171123221628.8313-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, Alexey Dobriyan <adobriyan@gmail.com>

Kmem cache alignment can't be negative.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/linux/slub_def.h | 2 +-
 mm/slub.c                | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 09ca236ce102..ff2d3f513d15 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -99,7 +99,7 @@ struct kmem_cache {
 	int refcount;		/* Refcount for slab cache destroy */
 	void (*ctor)(void *);
 	int inuse;		/* Offset to metadata */
-	int align;		/* Alignment */
+	unsigned int align;	/* Alignment */
 	unsigned int reserved;	/* Reserved bytes at the end of slabs */
 	unsigned int red_left_pad;	/* Left redzone padding size */
 	const char *name;	/* Name (only for display!) */
diff --git a/mm/slub.c b/mm/slub.c
index 2ca7463c72c2..ddfeb1d5c512 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4877,7 +4877,7 @@ SLAB_ATTR_RO(slab_size);
 
 static ssize_t align_show(struct kmem_cache *s, char *buf)
 {
-	return sprintf(buf, "%d\n", s->align);
+	return sprintf(buf, "%u\n", s->align);
 }
 SLAB_ATTR_RO(align);
 
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
