Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B0E786B0025
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 15:08:08 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id d23so4628653wmd.1
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 12:08:08 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e14sor2107741wmg.34.2018.03.05.12.08.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 12:08:07 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 16/25] slub: make ->offset unsigned int
Date: Mon,  5 Mar 2018 23:07:21 +0300
Message-Id: <20180305200730.15812-16-adobriyan@gmail.com>
In-Reply-To: <20180305200730.15812-1-adobriyan@gmail.com>
References: <20180305200730.15812-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, adobriyan@gmail.com

->offset is free pointer offset from the start of the object,
can't be negative.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/linux/slub_def.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index d2cc1391f17a..db00dbd7e89f 100644
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
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
