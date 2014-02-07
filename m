Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id E746F6B0038
	for <linux-mm@kvack.org>; Fri,  7 Feb 2014 07:08:53 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kp14so3108751pab.20
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 04:08:53 -0800 (PST)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id yy4si4803050pbc.309.2014.02.07.04.08.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 07 Feb 2014 04:08:52 -0800 (PST)
Received: by mail-pa0-f51.google.com with SMTP id ld10so3119326pab.38
        for <linux-mm@kvack.org>; Fri, 07 Feb 2014 04:08:51 -0800 (PST)
Date: Fri, 7 Feb 2014 17:38:47 +0530
From: Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH 5/9] mm: Mark functions as static in migrate.c
Message-ID: <2f62d7bb34ad1797b2990524239d4de90f8073a4.1391167128.git.rashika.kheria@gmail.com>
References: <a7658fc8f2ab015bffe83de1448cc3db79d2a9fc.1391167128.git.rashika.kheria@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <a7658fc8f2ab015bffe83de1448cc3db79d2a9fc.1391167128.git.rashika.kheria@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Ingo Molnar <mingo@kernel.org>, linux-mm@kvack.org, josh@joshtriplett.org

Mark functions as static in migrate.c because they are not used outside
this file.

This eliminates the following warnings in mm/migrate.c:
mm/migrate.c:1595:6: warning: no previous prototype for a??numamigrate_update_ratelimita?? [-Wmissing-prototypes]
mm/migrate.c:1619:5: warning: no previous prototype for a??numamigrate_isolate_pagea?? [-Wmissing-prototypes]

Signed-off-by: Rashika Kheria <rashika.kheria@gmail.com>
Reviewed-by: Josh Triplett <josh@joshtriplett.org>
---
 mm/migrate.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index bb94004..c916e73 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1592,7 +1592,8 @@ bool migrate_ratelimited(int node)
 }
 
 /* Returns true if the node is migrate rate-limited after the update */
-bool numamigrate_update_ratelimit(pg_data_t *pgdat, unsigned long nr_pages)
+static bool numamigrate_update_ratelimit(pg_data_t *pgdat,
+					 unsigned long nr_pages)
 {
 	bool rate_limited = false;
 
@@ -1616,7 +1617,7 @@ bool numamigrate_update_ratelimit(pg_data_t *pgdat, unsigned long nr_pages)
 	return rate_limited;
 }
 
-int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
+static int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
 {
 	int page_lru;
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
