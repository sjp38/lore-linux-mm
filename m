Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id ED45B6B0069
	for <linux-mm@kvack.org>; Wed, 28 Dec 2016 21:07:35 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id v84so744814022oie.0
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 18:07:35 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id y24si10961070oty.82.2016.12.28.18.07.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Dec 2016 18:07:35 -0800 (PST)
Message-ID: <58646FB7.2040502@huawei.com>
Date: Thu, 29 Dec 2016 10:06:47 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: mm: fix typo of cache_alloc_zspage()
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/zsmalloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 9cc3c0b..2d6c92e 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -364,7 +364,7 @@ static struct zspage *cache_alloc_zspage(struct zs_pool *pool, gfp_t flags)
 {
 	return kmem_cache_alloc(pool->zspage_cachep,
 			flags & ~(__GFP_HIGHMEM|__GFP_MOVABLE));
-};
+}
 
 static void cache_free_zspage(struct zs_pool *pool, struct zspage *zspage)
 {
-- 
1.8.3.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
