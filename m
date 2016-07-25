Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3842D6B0005
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 03:23:04 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id l89so109527897lfi.3
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 00:23:04 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id u1si13567926wjm.224.2016.07.25.00.23.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jul 2016 00:23:02 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 694AE1C196B
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 08:23:02 +0100 (IST)
Date: Mon, 25 Jul 2016 08:23:00 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH] mm: add per-zone lru list stat -fix
Message-ID: <20160725072300.GK10438@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Fengguang Wu <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

This patch renames the zone LRU stats as printed in /proc/vmstat to avoid
confusion. This keeps both the node and zone stats which normally will be
redundant but should always be roughly in sync.

This is a fix to the mmotm patch mm-add-per-zone-lru-list-stat.patch

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/vmstat.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index e1a46906c61b..89cec42d19ff 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -921,11 +921,11 @@ int fragmentation_index(struct zone *zone, unsigned int order)
 const char * const vmstat_text[] = {
 	/* enum zone_stat_item countes */
 	"nr_free_pages",
-	"nr_inactive_anon",
-	"nr_active_anon",
-	"nr_inactive_file",
-	"nr_active_file",
-	"nr_unevictable",
+	"nr_zone_inactive_anon",
+	"nr_zone_active_anon",
+	"nr_zone_inactive_file",
+	"nr_zone_active_file",
+	"nr_zone_unevictable",
 	"nr_zone_write_pending",
 	"nr_mlock",
 	"nr_slab_reclaimable",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
