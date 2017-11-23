Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id AAA846B0274
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 17:17:23 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id v69so9052763wrb.3
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 14:17:23 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k63sor7605759wrc.33.2017.11.23.14.17.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Nov 2017 14:17:22 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 15/23] slub: make ->offset unsigned int
Date: Fri, 24 Nov 2017 01:16:20 +0300
Message-Id: <20171123221628.8313-15-adobriyan@gmail.com>
In-Reply-To: <20171123221628.8313-1-adobriyan@gmail.com>
References: <20171123221628.8313-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, Alexey Dobriyan <adobriyan@gmail.com>

->offset is free pointer offset from the start of the object,
can't be negative.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/linux/slub_def.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index d8b40e53e8f6..94f1228f2f41 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -86,7 +86,7 @@ struct kmem_cache {
 	unsigned long min_partial;
 	int size;		/* The size of an object including meta data */
 	int object_size;	/* The size of an object without meta data */
-	int offset;		/* Free pointer offset. */
+	unsigned int offset;	/* Free pointer offset. */
 #ifdef CONFIG_SLUB_CPU_PARTIAL
 	/* Number of per cpu partial objects to keep around */
 	unsigned int cpu_partial;
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
