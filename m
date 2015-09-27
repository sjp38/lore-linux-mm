Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 1E5D96B0254
	for <linux-mm@kvack.org>; Sun, 27 Sep 2015 14:04:48 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so77725404wic.0
        for <linux-mm@kvack.org>; Sun, 27 Sep 2015 11:04:47 -0700 (PDT)
Received: from mail-wi0-x233.google.com (mail-wi0-x233.google.com. [2a00:1450:400c:c05::233])
        by mx.google.com with ESMTPS id jj5si17252141wid.119.2015.09.27.11.04.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Sep 2015 11:04:47 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so77327600wic.1
        for <linux-mm@kvack.org>; Sun, 27 Sep 2015 11:04:46 -0700 (PDT)
Date: Sun, 27 Sep 2015 21:04:25 +0000
From: Alexandru Moise <00moses.alexander00@gmail.com>
Subject: [PATCH 2/2] mm: fix declarations of nr, delta and
 nr_pagecache_reclaimable
Message-ID: <20150927210425.GA20155@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: vdavydov@parallels.com, mhocko@suse.cz, hannes@cmpxchg.org, tj@kernel.org, vbabka@suse.cz, mgorman@suse.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org

The nr variable is meant to be returned by a function which is
declared as returning "unsigned long", so declare nr as such.

Lower down we should also declare delta and nr_pagecache_reclaimable
as being unsigned longs because they're used to store the values
returned by zone_page_state() and zone_unmapped_file_pages() which
also happen to return unsigned integers.

Signed-off-by: Alexandru Moise <00moses.alexander00@gmail.com>
---
 mm/vmscan.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 7f63a93..41e254e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -194,7 +194,7 @@ static bool sane_reclaim(struct scan_control *sc)
 
 static unsigned long zone_reclaimable_pages(struct zone *zone)
 {
-	int nr;
+	unsigned long nr;
 
 	nr = zone_page_state(zone, NR_ACTIVE_FILE) +
 	     zone_page_state(zone, NR_INACTIVE_FILE);
@@ -3698,8 +3698,8 @@ static inline unsigned long zone_unmapped_file_pages(struct zone *zone)
 /* Work out how many page cache pages we can reclaim in this reclaim_mode */
 static long zone_pagecache_reclaimable(struct zone *zone)
 {
-	long nr_pagecache_reclaimable;
-	long delta = 0;
+	unsigned long nr_pagecache_reclaimable;
+	unsigned long delta = 0;
 
 	/*
 	 * If RECLAIM_UNMAP is set, then all file pages are considered
-- 
2.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
