Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 8A1326B0269
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:14:32 -0400 (EDT)
Received: by mail-wm0-f51.google.com with SMTP id f198so134587263wme.0
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 01:14:32 -0700 (PDT)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id a87si17058039wmi.78.2016.04.11.01.14.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 01:14:31 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 4C7F91C11CC
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 09:14:31 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 11/22] mm, page_alloc: Remove unnecessary initialisation in get_page_from_freelist
Date: Mon, 11 Apr 2016 09:13:34 +0100
Message-Id: <1460362424-26369-12-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460362424-26369-1-git-send-email-mgorman@techsingularity.net>
References: <1460362424-26369-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

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
