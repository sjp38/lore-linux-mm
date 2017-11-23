Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 069556B026F
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 17:17:20 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id k100so12748681wrc.9
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 14:17:19 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u126sor1673292wmd.77.2017.11.23.14.17.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Nov 2017 14:17:18 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 11/23] slub: make ->reserved unsigned int
Date: Fri, 24 Nov 2017 01:16:16 +0300
Message-Id: <20171123221628.8313-11-adobriyan@gmail.com>
In-Reply-To: <20171123221628.8313-1-adobriyan@gmail.com>
References: <20171123221628.8313-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, Alexey Dobriyan <adobriyan@gmail.com>

->reserved is either 0 or sizeof(struct rcu_head), can't be negative.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/linux/slub_def.h | 2 +-
 mm/slub.c                | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index a7019a4c713d..09ca236ce102 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -100,7 +100,7 @@ struct kmem_cache {
 	void (*ctor)(void *);
 	int inuse;		/* Offset to metadata */
 	int align;		/* Alignment */
-	int reserved;		/* Reserved bytes at the end of slabs */
+	unsigned int reserved;	/* Reserved bytes at the end of slabs */
 	unsigned int red_left_pad;	/* Left redzone padding size */
 	const char *name;	/* Name (only for display!) */
 	struct list_head list;	/* List of slab caches */
diff --git a/mm/slub.c b/mm/slub.c
index 45d8f0cbfb28..2ca7463c72c2 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5069,7 +5069,7 @@ SLAB_ATTR_RO(destroy_by_rcu);
 
 static ssize_t reserved_show(struct kmem_cache *s, char *buf)
 {
-	return sprintf(buf, "%d\n", s->reserved);
+	return sprintf(buf, "%u\n", s->reserved);
 }
 SLAB_ATTR_RO(reserved);
 
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
