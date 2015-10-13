Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id B44526B0253
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 02:31:19 -0400 (EDT)
Received: by pabve7 with SMTP id ve7so11738917pab.2
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 23:31:19 -0700 (PDT)
Received: from xiaomi.com (outboundhk.mxmail.xiaomi.com. [207.226.244.122])
        by mx.google.com with ESMTPS id nu8si2735759pbb.87.2015.10.12.23.31.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 12 Oct 2015 23:31:18 -0700 (PDT)
From: Hui Zhu <zhuhui@xiaomi.com>
Subject: [PATCH] zsmalloc: remove unless line in obj_free
Date: Tue, 13 Oct 2015 14:31:02 +0800
Message-ID: <1444717862-27234-1-git-send-email-zhuhui@xiaomi.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: teawater@gmail.com, Hui Zhu <zhuhui@xiaomi.com>

Signed-off-by: Hui Zhu <zhuhui@xiaomi.com>
---
 mm/zsmalloc.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index f135b1b..c7338f0 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -1428,8 +1428,6 @@ static void obj_free(struct zs_pool *pool, struct size_class *class,
 	struct page *first_page, *f_page;
 	unsigned long f_objidx, f_offset;
 	void *vaddr;
-	int class_idx;
-	enum fullness_group fullness;
 
 	BUG_ON(!obj);
 
@@ -1437,7 +1435,6 @@ static void obj_free(struct zs_pool *pool, struct size_class *class,
 	obj_to_location(obj, &f_page, &f_objidx);
 	first_page = get_first_page(f_page);
 
-	get_zspage_mapping(first_page, &class_idx, &fullness);
 	f_offset = obj_idx_to_offset(f_page, f_objidx, class->size);
 
 	vaddr = kmap_atomic(f_page);
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
