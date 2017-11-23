Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id EBA096B026E
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 17:17:18 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id j6so10432309wre.16
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 14:17:18 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i8sor680561wre.3.2017.11.23.14.17.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Nov 2017 14:17:17 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 10/23] slub: make ->red_left_pad unsigned int
Date: Fri, 24 Nov 2017 01:16:15 +0300
Message-Id: <20171123221628.8313-10-adobriyan@gmail.com>
In-Reply-To: <20171123221628.8313-1-adobriyan@gmail.com>
References: <20171123221628.8313-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, Alexey Dobriyan <adobriyan@gmail.com>

Padding length can't be negative.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/linux/slub_def.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 5e98817e18a3..a7019a4c713d 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -101,7 +101,7 @@ struct kmem_cache {
 	int inuse;		/* Offset to metadata */
 	int align;		/* Alignment */
 	int reserved;		/* Reserved bytes at the end of slabs */
-	int red_left_pad;	/* Left redzone padding size */
+	unsigned int red_left_pad;	/* Left redzone padding size */
 	const char *name;	/* Name (only for display!) */
 	struct list_head list;	/* List of slab caches */
 #ifdef CONFIG_SYSFS
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
