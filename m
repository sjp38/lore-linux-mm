Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6195C6B03A8
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 09:54:40 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 132so36986395pgb.6
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 06:54:40 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id s187si5289003pgb.326.2017.06.19.06.54.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 06:54:39 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id y7so17102914pfd.3
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 06:54:39 -0700 (PDT)
From: Hao Lee <haolee.swjtu@gmail.com>
Subject: [PATCH] mm: remove a redundant condition in the for loop
Date: Mon, 19 Jun 2017 21:54:18 +0800
Message-Id: <20170619135418.8580-1-haolee.swjtu@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: vbabka@suse.cz, mgorman@techsingularity.net, mhocko@suse.com, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hao Lee <haolee.swjtu@gmail.com>

The variable current_order decreases from MAX_ORDER-1 to order, so the
condition current_order <= MAX_ORDER-1 is always true.

Signed-off-by: Hao Lee <haolee.swjtu@gmail.com>
---
 mm/page_alloc.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2302f25..9120c2b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2215,9 +2215,8 @@ __rmqueue_fallback(struct zone *zone, unsigned int order, int start_migratetype)
 	bool can_steal;
 
 	/* Find the largest possible block of pages in the other list */
-	for (current_order = MAX_ORDER-1;
-				current_order >= order && current_order <= MAX_ORDER-1;
-				--current_order) {
+	for (current_order = MAX_ORDER-1; current_order >= order;
+							--current_order) {
 		area = &(zone->free_area[current_order]);
 		fallback_mt = find_suitable_fallback(area, current_order,
 				start_migratetype, false, &can_steal);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
