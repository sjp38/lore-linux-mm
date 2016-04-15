Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id D8CA96B0267
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 05:01:24 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id l15so63905079lfg.2
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 02:01:24 -0700 (PDT)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id w195si39011055wmd.112.2016.04.15.02.01.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 15 Apr 2016 02:01:23 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id 4BF6FCECB
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 09:01:23 +0000 (UTC)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 11/28] mm, page_alloc: Remove unnecessary initialisation in get_page_from_freelist
Date: Fri, 15 Apr 2016 09:59:03 +0100
Message-Id: <1460710760-32601-12-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

See subject.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 313db1c43839..f5ddb342c967 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2674,7 +2674,6 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 						const struct alloc_context *ac)
 {
 	struct zoneref *z;
-	struct page *page = NULL;
 	struct zone *zone;
 	bool fair_skipped;
 	bool zonelist_rescan;
@@ -2688,6 +2687,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 	 */
 	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx,
 								ac->nodemask) {
+		struct page *page;
 		unsigned long mark;
 
 		if (cpusets_enabled() &&
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
