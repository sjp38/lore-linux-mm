Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 565D76B02F3
	for <linux-mm@kvack.org>; Sat, 24 Jun 2017 00:34:38 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id s65so56813143pfi.14
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 21:34:38 -0700 (PDT)
Received: from mail-pf0-x244.google.com (mail-pf0-x244.google.com. [2607:f8b0:400e:c00::244])
        by mx.google.com with ESMTPS id u17si5004459plj.480.2017.06.23.21.34.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jun 2017 21:34:37 -0700 (PDT)
Received: by mail-pf0-x244.google.com with SMTP id s66so10097767pfs.2
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 21:34:37 -0700 (PDT)
From: john.hubbard@gmail.com
Subject: [PATCH 1/1] mm: remove unused zone_type variable from __remove_zone()
Date: Fri, 23 Jun 2017 21:34:21 -0700
Message-Id: <20170624043421.24465-2-jhubbard@nvidia.com>
In-Reply-To: <20170624043421.24465-1-jhubbard@nvidia.com>
References: <20170624043421.24465-1-jhubbard@nvidia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>

From: John Hubbard <jhubbard@nvidia.com>

__remove_zone() is setting up zone_type, but never using
it for anything. This is not causing a warning, due to
the (necessary) use of -Wno-unused-but-set-variable.
However, it's noise, so just delete it.

Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 mm/memory_hotplug.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 567a1dcafa1a..9bd73ecd7248 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -580,11 +580,8 @@ static void __remove_zone(struct zone *zone, unsigned long start_pfn)
 {
 	struct pglist_data *pgdat = zone->zone_pgdat;
 	int nr_pages = PAGES_PER_SECTION;
-	int zone_type;
 	unsigned long flags;
 
-	zone_type = zone - pgdat->node_zones;
-
 	pgdat_resize_lock(zone->zone_pgdat, &flags);
 	shrink_zone_span(zone, start_pfn, start_pfn + nr_pages);
 	shrink_pgdat_span(pgdat, start_pfn, start_pfn + nr_pages);
-- 
2.13.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
