Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f179.google.com (mail-ea0-f179.google.com [209.85.215.179])
	by kanga.kvack.org (Postfix) with ESMTP id 85D406B0069
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 02:09:26 -0500 (EST)
Received: by mail-ea0-f179.google.com with SMTP id r15so1349025ead.38
        for <linux-mm@kvack.org>; Sun, 08 Dec 2013 23:09:26 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id h45si8222292eeo.130.2013.12.08.23.09.25
        for <linux-mm@kvack.org>;
        Sun, 08 Dec 2013 23:09:25 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 13/18] mm: numa: Make NUMA-migrate related functions static
Date: Mon,  9 Dec 2013 07:09:07 +0000
Message-Id: <1386572952-1191-14-git-send-email-mgorman@suse.de>
In-Reply-To: <1386572952-1191-1-git-send-email-mgorman@suse.de>
References: <1386572952-1191-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alex Thorlton <athorlton@sgi.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

numamigrate_update_ratelimit and numamigrate_isolate_page only have callers
in mm/migrate.c. This patch makes them static.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/migrate.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 5372521..77147bd 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1593,7 +1593,8 @@ bool migrate_ratelimited(int node)
 }
 
 /* Returns true if the node is migrate rate-limited after the update */
-bool numamigrate_update_ratelimit(pg_data_t *pgdat, unsigned long nr_pages)
+static bool numamigrate_update_ratelimit(pg_data_t *pgdat,
+					unsigned long nr_pages)
 {
 	bool rate_limited = false;
 
@@ -1617,7 +1618,7 @@ bool numamigrate_update_ratelimit(pg_data_t *pgdat, unsigned long nr_pages)
 	return rate_limited;
 }
 
-int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
+static int numamigrate_isolate_page(pg_data_t *pgdat, struct page *page)
 {
 	int page_lru;
 
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
