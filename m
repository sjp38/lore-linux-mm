Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5F4FB6B0038
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 10:25:08 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id r9so224125838ywg.0
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 07:25:08 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id g64si809705uag.19.2016.08.23.07.25.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 23 Aug 2016 07:25:07 -0700 (PDT)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH] mm: page should be aligned with max_order
Date: Tue, 23 Aug 2016 22:10:00 +0800
Message-ID: <1471961400-1536-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vbabka@suse.cz, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org

From: zhong jiang <zhongjiang@huawei.com>

At present, page aligned with MAX_ORDER make no sense.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ff726f94..a178b1d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -786,7 +786,7 @@ static inline void __free_one_page(struct page *page,
 	if (likely(!is_migrate_isolate(migratetype)))
 		__mod_zone_freepage_state(zone, 1 << order, migratetype);
 
-	page_idx = pfn & ((1 << MAX_ORDER) - 1);
+	page_idx = pfn & ((1 << max_order) - 1);
 
 	VM_BUG_ON_PAGE(page_idx & ((1 << order) - 1), page);
 	VM_BUG_ON_PAGE(bad_range(zone, page), page);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
