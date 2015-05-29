Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 506956B0092
	for <linux-mm@kvack.org>; Fri, 29 May 2015 11:06:42 -0400 (EDT)
Received: by pdea3 with SMTP id a3so55497877pde.2
        for <linux-mm@kvack.org>; Fri, 29 May 2015 08:06:42 -0700 (PDT)
Received: from mail-pd0-x22f.google.com (mail-pd0-x22f.google.com. [2607:f8b0:400e:c02::22f])
        by mx.google.com with ESMTPS id gf9si8744684pbc.213.2015.05.29.08.06.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 08:06:41 -0700 (PDT)
Received: by pdea3 with SMTP id a3so55497552pde.2
        for <linux-mm@kvack.org>; Fri, 29 May 2015 08:06:41 -0700 (PDT)
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: [RFC][PATCH 08/10] zsmalloc: export zs_pool `num_migrated'
Date: Sat, 30 May 2015 00:05:26 +0900
Message-Id: <1432911928-14654-9-git-send-email-sergey.senozhatsky@gmail.com>
In-Reply-To: <1432911928-14654-1-git-send-email-sergey.senozhatsky@gmail.com>
References: <1432911928-14654-1-git-send-email-sergey.senozhatsky@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

introduce zs_get_num_migrated() to export zs_pool's ->num_migrated
counter.

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
---
 include/linux/zsmalloc.h | 1 +
 mm/zsmalloc.c            | 7 +++++++
 2 files changed, 8 insertions(+)

diff --git a/include/linux/zsmalloc.h b/include/linux/zsmalloc.h
index 1338190..e878875 100644
--- a/include/linux/zsmalloc.h
+++ b/include/linux/zsmalloc.h
@@ -47,6 +47,7 @@ void *zs_map_object(struct zs_pool *pool, unsigned long handle,
 void zs_unmap_object(struct zs_pool *pool, unsigned long handle);
 
 unsigned long zs_get_total_pages(struct zs_pool *pool);
+unsigned long zs_get_num_migrated(struct zs_pool *pool);
 unsigned long zs_compact(struct zs_pool *pool);
 
 #endif
diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 70bf481..0524c4a 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1543,6 +1543,13 @@ unsigned long zs_get_total_pages(struct zs_pool *pool)
 }
 EXPORT_SYMBOL_GPL(zs_get_total_pages);
 
+unsigned long zs_get_num_migrated(struct zs_pool *pool)
+{
+	/* can be outdated */
+	return pool->num_migrated;
+}
+EXPORT_SYMBOL_GPL(zs_get_num_migrated);
+
 /**
  * zs_map_object - get address of allocated object from handle.
  * @pool: pool from which the object was allocated
-- 
2.4.2.337.gfae46aa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
