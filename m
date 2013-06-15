Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 2EE1D6B0033
	for <linux-mm@kvack.org>; Sat, 15 Jun 2013 07:05:48 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id w11so1334793pde.9
        for <linux-mm@kvack.org>; Sat, 15 Jun 2013 04:05:47 -0700 (PDT)
Message-ID: <51BC4A83.50302@gmail.com>
Date: Sat, 15 Jun 2013 19:05:39 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: [PATCH] mm: Add unlikely for current_order test
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

Since we have an unlikely for the "current_order >= pageblock_order / 2"
test above, adding an unlikely for this "current_order >= pageblock_order"
test seems more appropriate.

Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 mm/page_alloc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c3edb62..1b6d7de 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1071,7 +1071,7 @@ __rmqueue_fallback(struct zone *zone, int order, int start_migratetype)
 			rmv_page_order(page);
 
 			/* Take ownership for orders >= pageblock_order */
-			if (current_order >= pageblock_order &&
+			if (unlikely(current_order >= pageblock_order) &&
 			    !is_migrate_cma(migratetype))
 				change_pageblock_range(page, current_order,
 							start_migratetype);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
