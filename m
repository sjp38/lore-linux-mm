Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 519AF6B0279
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 19:19:35 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c12so12569539pfj.12
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 16:19:35 -0700 (PDT)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id h17si806466pgn.512.2017.06.26.16.19.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jun 2017 16:19:34 -0700 (PDT)
Received: by mail-pf0-x242.google.com with SMTP id s66so2161060pfs.2
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 16:19:34 -0700 (PDT)
From: Wei Yang <richard.weiyang@gmail.com>
Subject: [PATCH] mm/memory_hotplug: remove an unused variable in move_pfn_range_to_zone()
Date: Tue, 27 Jun 2017 07:19:28 +0800
Message-Id: <20170626231928.54565-1-richard.weiyang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wei Yang <richard.weiyang@gmail.com>

There is an unused variable in move_pfn_range_to_zone().

This patch just removes it.

Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
---
 mm/memory_hotplug.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 514014dde16b..16167c92bbf1 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -899,7 +899,6 @@ void __ref move_pfn_range_to_zone(struct zone *zone,
 	struct pglist_data *pgdat = zone->zone_pgdat;
 	int nid = pgdat->node_id;
 	unsigned long flags;
-	unsigned long i;
 
 	if (zone_is_empty(zone))
 		init_currently_empty_zone(zone, start_pfn, nr_pages);
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
