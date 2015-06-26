Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id A06F96B0038
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 21:46:16 -0400 (EDT)
Received: by ieqy10 with SMTP id y10so66700321ieq.0
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 18:46:16 -0700 (PDT)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com. [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id mf1si54914igb.43.2015.06.25.18.46.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jun 2015 18:46:16 -0700 (PDT)
Received: by igblr2 with SMTP id lr2so4372792igb.0
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 18:46:16 -0700 (PDT)
From: Nicholas Krause <xerofoify@gmail.com>
Subject: [PATCH] mm:Change function return from int to bool for the function is_page_busy
Date: Thu, 25 Jun 2015 21:46:10 -0400
Message-Id: <1435283170-17056-1-git-send-email-xerofoify@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: bigeasy@linutronix.de, paulmcquad@gmail.com, khalasa@piap.pl, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This makes the function is_page_busy's return bool rather then
an int now due to this particular function's single return
statement only ever evaulating to either one or zero.

Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
---
 mm/dmapool.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/dmapool.c b/mm/dmapool.c
index fd5fe43..59d10d1 100644
--- a/mm/dmapool.c
+++ b/mm/dmapool.c
@@ -242,7 +242,7 @@ static struct dma_page *pool_alloc_page(struct dma_pool *pool, gfp_t mem_flags)
 	return page;
 }
 
-static inline int is_page_busy(struct dma_page *page)
+static inline bool is_page_busy(struct dma_page *page)
 {
 	return page->in_use != 0;
 }
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
