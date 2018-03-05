Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 76BE16B0022
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 15:08:05 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id q15so11755833wra.22
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 12:08:05 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p12sor2449097wmc.8.2018.03.05.12.08.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 12:08:04 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 13/25] slub: make ->align unsigned int
Date: Mon,  5 Mar 2018 23:07:18 +0300
Message-Id: <20180305200730.15812-13-adobriyan@gmail.com>
In-Reply-To: <20180305200730.15812-1-adobriyan@gmail.com>
References: <20180305200730.15812-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, adobriyan@gmail.com

Kmem cache alignment can't be negative.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/linux/slub_def.h | 2 +-
 mm/slub.c                | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 2b4417aa15d8..2a0eabeff78f 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -99,7 +99,7 @@ struct kmem_cache {
 	int refcount;		/* Refcount for slab cache destroy */
 	void (*ctor)(void *);
 	int inuse;		/* Offset to metadata */
-	int align;		/* Alignment */
+	unsigned int align;		/* Alignment */
 	unsigned int reserved;		/* Reserved bytes at the end of slabs */
 	unsigned int red_left_pad;	/* Left redzone padding size */
 	const char *name;	/* Name (only for display!) */
diff --git a/mm/slub.c b/mm/slub.c
index 72623f210892..246f0132d308 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -4895,7 +4895,7 @@ SLAB_ATTR_RO(slab_size);
 
 static ssize_t align_show(struct kmem_cache *s, char *buf)
 {
-	return sprintf(buf, "%d\n", s->align);
+	return sprintf(buf, "%u\n", s->align);
 }
 SLAB_ATTR_RO(align);
 
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
