Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 349292802C8
	for <linux-mm@kvack.org>; Mon,  6 Jul 2015 19:30:36 -0400 (EDT)
Received: by iecuq6 with SMTP id uq6so123705360iec.2
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 16:30:36 -0700 (PDT)
Received: from mail-ie0-x230.google.com (mail-ie0-x230.google.com. [2607:f8b0:4001:c03::230])
        by mx.google.com with ESMTPS id g20si14253947igt.61.2015.07.06.16.30.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jul 2015 16:30:35 -0700 (PDT)
Received: by iecvh10 with SMTP id vh10so123908196iec.3
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 16:30:35 -0700 (PDT)
From: Nicholas Krause <xerofoify@gmail.com>
Subject: [PATCH] mm:Change unlabeled block of code to a else block in the function dma_pool_free
Date: Mon,  6 Jul 2015 19:30:31 -0400
Message-Id: <1436225431-5880-1-git-send-email-xerofoify@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: khalasa@piap.pl, bigeasy@linutronix.de, paulmcquad@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

This fixes the unlabeled block of code after the if statement that
executes if the passed dma variable of type dma_addr_t minus the
structure pointer page's dma member is equal to the variable offset
into a else block as this block should run when the if statement check

Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
---
 mm/dmapool.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/dmapool.c b/mm/dmapool.c
index fd5fe43..ce7ff4b 100644
--- a/mm/dmapool.c
+++ b/mm/dmapool.c
@@ -434,8 +434,7 @@ void dma_pool_free(struct dma_pool *pool, void *vaddr, dma_addr_t dma)
 			       "dma_pool_free %s, %p (bad vaddr)/%Lx\n",
 			       pool->name, vaddr, (unsigned long long)dma);
 		return;
-	}
-	{
+	} else {
 		unsigned int chain = page->offset;
 		while (chain < pool->allocation) {
 			if (chain != offset) {
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
