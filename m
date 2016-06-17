Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id A024B6B0005
	for <linux-mm@kvack.org>; Fri, 17 Jun 2016 10:00:52 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id x6so139124343oif.0
        for <linux-mm@kvack.org>; Fri, 17 Jun 2016 07:00:52 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id k20si15741978oih.102.2016.06.17.07.00.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 17 Jun 2016 07:00:51 -0700 (PDT)
From: zhongjiang <zhongjiang@huawei.com>
Subject: [PATCH] mm: update the comment in __isolate_free_page
Date: Fri, 17 Jun 2016 21:58:34 +0800
Message-ID: <1466171914-21027-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: zhong jiang <zhongjiang@huawei.com>

we need to assure the code is consistent with comment. otherwise,
Freshman feel hard to learn it.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6903b69..3842400 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2509,7 +2509,7 @@ int __isolate_free_page(struct page *page, unsigned int order)
 
 	set_page_owner(page, order, __GFP_MOVABLE);
 
-	/* Set the pageblock if the isolated page is at least a pageblock */
+	/* Set the pageblock if the isolated page is at least half of a pageblock */
 	if (order >= pageblock_order - 1) {
 		struct page *endpage = page + (1 << order) - 1;
 		for (; page < endpage; page += pageblock_nr_pages) {
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
