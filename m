Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5028E6B0069
	for <linux-mm@kvack.org>; Thu, 29 Dec 2016 02:59:39 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id x140so62954575lfa.2
        for <linux-mm@kvack.org>; Wed, 28 Dec 2016 23:59:39 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id v126si30495034lfa.190.2016.12.28.23.59.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Dec 2016 23:59:37 -0800 (PST)
Message-ID: <5864C12F.60709@huawei.com>
Date: Thu, 29 Dec 2016 15:54:23 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: [PATCH V2] mm: fix typo of cache_alloc_zspage()
References: <58646FB7.2040502@huawei.com>
In-Reply-To: <58646FB7.2040502@huawei.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Delete extra semicolon, it was introduced in
3783689 zsmalloc: introduce zspage structure

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
