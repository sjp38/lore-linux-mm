Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C72DE828E1
	for <linux-mm@kvack.org>; Mon,  4 Jul 2016 02:51:42 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id g62so376073493pfb.3
        for <linux-mm@kvack.org>; Sun, 03 Jul 2016 23:51:42 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id f15si2581445pap.97.2016.07.03.23.51.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Jul 2016 23:51:42 -0700 (PDT)
Received: by mail-pa0-x244.google.com with SMTP id lm4so3894420pab.3
        for <linux-mm@kvack.org>; Sun, 03 Jul 2016 23:51:42 -0700 (PDT)
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: [PATCH v2 6/8] mm/zsmalloc: keep comments consistent with code
Date: Mon,  4 Jul 2016 14:49:57 +0800
Message-Id: <1467614999-4326-6-git-send-email-opensource.ganesh@gmail.com>
In-Reply-To: <1467614999-4326-1-git-send-email-opensource.ganesh@gmail.com>
References: <1467614999-4326-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, minchan@kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, rostedt@goodmis.org, mingo@redhat.com, Ganesh Mahendran <opensource.ganesh@gmail.com>

some minor change of comments:
1). update zs_malloc(),zs_create_pool() function header
2). update "Usage of struct page fields"

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
----
v2:
    change *object index* to *object offset* - Minchan
---
 mm/zsmalloc.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 2c4549e..df804b8 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -20,6 +20,7 @@
  *	page->freelist(index): links together all component pages of a zspage
  *		For the huge page, this is always 0, so we use this field
  *		to store handle.
+ *	page->units: first object offset in a subpage of zspage
  *
  * Usage of struct page flags:
  *	PG_private: identifies the first component page
@@ -140,9 +141,6 @@
  */
 #define ZS_SIZE_CLASS_DELTA	(PAGE_SIZE >> CLASS_BITS)
 
-/*
- * We do not maintain any list for completely empty or full pages
- */
 enum fullness_group {
 	ZS_EMPTY,
 	ZS_ALMOST_EMPTY,
@@ -1535,6 +1533,7 @@ static unsigned long obj_malloc(struct size_class *class,
  * zs_malloc - Allocate block of given size from pool.
  * @pool: pool to allocate from
  * @size: size of block to allocate
+ * @gfp: gfp flags when allocating object
  *
  * On success, handle to the allocated object is returned,
  * otherwise 0.
@@ -2400,7 +2399,7 @@ static int zs_register_shrinker(struct zs_pool *pool)
 
 /**
  * zs_create_pool - Creates an allocation pool to work from.
- * @flags: allocation flags used to allocate pool metadata
+ * @name: pool name to be created
  *
  * This function must be called before anything when using
  * the zsmalloc allocator.
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
