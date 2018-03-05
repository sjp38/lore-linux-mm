Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 01C416B0010
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 15:08:02 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id m78so2103008wma.7
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 12:08:01 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 12sor1050923wmn.86.2018.03.05.12.08.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 12:08:00 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 10/25] slub: make ->max_attr_size unsigned int
Date: Mon,  5 Mar 2018 23:07:15 +0300
Message-Id: <20180305200730.15812-10-adobriyan@gmail.com>
In-Reply-To: <20180305200730.15812-1-adobriyan@gmail.com>
References: <20180305200730.15812-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, adobriyan@gmail.com

->max_attr_size is maximum length of every SLAB memcg attribute
ever written. VFS limits those to INT_MAX.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/linux/slub_def.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index f6548083fe0f..9bb761324a9c 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -110,7 +110,8 @@ struct kmem_cache {
 #endif
 #ifdef CONFIG_MEMCG
 	struct memcg_cache_params memcg_params;
-	int max_attr_size; /* for propagation, maximum size of a stored attr */
+	/* for propagation, maximum size of a stored attr */
+	unsigned int max_attr_size;
 #ifdef CONFIG_SYSFS
 	struct kset *memcg_kset;
 #endif
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
