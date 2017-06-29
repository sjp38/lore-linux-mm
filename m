Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 987522802FE
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 21:10:50 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j79so71456621pfj.9
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 18:10:50 -0700 (PDT)
Received: from out28-98.mail.aliyun.com (out28-98.mail.aliyun.com. [115.124.28.98])
        by mx.google.com with ESMTP id r9si2590559pgu.401.2017.06.28.18.10.43
        for <linux-mm@kvack.org>;
        Wed, 28 Jun 2017 18:10:49 -0700 (PDT)
From: "zhenwei.pi" <zhenwei.pi@youruncloud.com>
Subject: [PATCH] mm: balloon: enqueue zero page to balloon device
Date: Thu, 29 Jun 2017 09:10:37 +0800
Message-Id: <1498698637-26389-1-git-send-email-zhenwei.pi@youruncloud.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, gi-oh.kim@profitbricks.com, vbabka@suse.cz, zhenwei.pi@youruncloud.com

Now, pages in balloon device have random value, and these pages
will be scanned by ksmd on host. They usually can not be merged.
Enqueue zero page will resolve this problem.

Signed-off-by: zhenwei.pi <zhenwei.pi@youruncloud.com>
---
 mm/balloon_compaction.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/balloon_compaction.c b/mm/balloon_compaction.c
index da91df5..c29ebdc 100644
--- a/mm/balloon_compaction.c
+++ b/mm/balloon_compaction.c
@@ -24,7 +24,7 @@ struct page *balloon_page_enqueue(struct balloon_dev_info *b_dev_info)
 {
 	unsigned long flags;
 	struct page *page = alloc_page(balloon_mapping_gfp_mask() |
-					__GFP_NOMEMALLOC | __GFP_NORETRY);
+					__GFP_NOMEMALLOC | __GFP_NORETRY | __GFP_ZERO);
 	if (!page)
 		return NULL;
 
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
