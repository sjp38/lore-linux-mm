Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 78E196B007E
	for <linux-mm@kvack.org>; Sun, 19 Jun 2016 04:54:54 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 143so251560960pfx.0
        for <linux-mm@kvack.org>; Sun, 19 Jun 2016 01:54:54 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id b66si25126257pfg.52.2016.06.19.01.54.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Jun 2016 01:54:53 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id i123so6313542pfg.3
        for <linux-mm@kvack.org>; Sun, 19 Jun 2016 01:54:53 -0700 (PDT)
From: YOSHIDA Masanori <masanori.yoshida.lkml@gmail.com>
Subject: [PATCH] Delete meaningless check of current_order in __rmqueue_fallback
Date: Mon, 13 Jun 2016 03:03:31 +0900
Message-Id: <1465754611-21398-1-git-send-email-masanori.yoshida.lkml@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, mgorman@techsingularity.net, vbabka@suse.cz, mhocko@suse.com, rientjes@google.com, iamjoonsoo.kim@lge.com, izumi.taku@jp.fujitsu.com, hannes@cmpxchg.org, linux-mm@kvack.org, YOSHIDA Masanori <masanori.yoshida@gmail.com>

From: YOSHIDA Masanori <masanori.yoshida@gmail.com>

Signed-off-by: YOSHIDA Masanori <masanori.yoshida@gmail.com>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6903b69..db02967 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2105,7 +2105,7 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
 
 	/* Find the largest possible block of pages in the other list */
 	for (current_order = MAX_ORDER-1;
-				current_order >= order && current_order <= MAX_ORDER-1;
+				current_order >= order;
 				--current_order) {
 		area = &(zone->free_area[current_order]);
 		fallback_mt = find_suitable_fallback(area, current_order,
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
