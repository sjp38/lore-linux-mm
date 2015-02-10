Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com [209.85.218.48])
	by kanga.kvack.org (Postfix) with ESMTP id CE7286B0032
	for <linux-mm@kvack.org>; Tue, 10 Feb 2015 08:47:47 -0500 (EST)
Received: by mail-oi0-f48.google.com with SMTP id a3so10000367oib.7
        for <linux-mm@kvack.org>; Tue, 10 Feb 2015 05:47:47 -0800 (PST)
Received: from m50-138.163.com (m50-138.163.com. [123.125.50.138])
        by mx.google.com with ESMTP id u10si7533777oem.34.2015.02.10.05.47.45
        for <linux-mm@kvack.org>;
        Tue, 10 Feb 2015 05:47:46 -0800 (PST)
From: Yaowei Bai <bywxiaobai@163.com>
Subject: [PATCH] mm/page_alloc: add a necessary 'leave'
Date: Tue, 10 Feb 2015 21:43:39 +0800
Message-Id: <1423575819-3813-1-git-send-email-bywxiaobai@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, hannes@cmpxchg.org, riel@redhat.com, iamjoonsoo.kim@lge.com, rientjes@google.com, sasha.levin@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Signed-off-by: Yaowei Bai <bywxiaobai@163.com>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7633c50..c88d495 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -172,7 +172,7 @@ static void __free_pages_ok(struct page *page, unsigned int order);
  *	1G machine -> (16M dma, 784M normal, 224M high)
  *	NORMAL allocation will leave 784M/256 of ram reserved in the ZONE_DMA
  *	HIGHMEM allocation will leave 224M/32 of ram reserved in ZONE_NORMAL
- *	HIGHMEM allocation will (224M+784M)/256 of ram reserved in ZONE_DMA
+ *	HIGHMEM allocation will leave (224M+784M)/256 of ram reserved in ZONE_DMA
  *
  * TBD: should special case ZONE_DMA32 machines here - in those we normally
  * don't need any ZONE_NORMAL reservation
-- 
1.9.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
