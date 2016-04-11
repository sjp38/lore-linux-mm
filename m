Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 020DE6B0268
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 04:14:29 -0400 (EDT)
Received: by mail-wm0-f43.google.com with SMTP id u206so93160170wme.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 01:14:28 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id x131si17072646wmb.35.2016.04.11.01.14.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 01:14:28 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id B60AE1C18A6
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 09:14:27 +0100 (IST)
From: Mel Gorman <mgorman@techsingularity.net>
Subject: [PATCH 10/22] mm, page_alloc: Remove unnecessary local variable in get_page_from_freelist
Date: Mon, 11 Apr 2016 09:13:33 +0100
Message-Id: <1460362424-26369-11-git-send-email-mgorman@techsingularity.net>
In-Reply-To: <1460362424-26369-1-git-send-email-mgorman@techsingularity.net>
References: <1460362424-26369-1-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

zonelist here is a copy of a struct field that is used once. Ditch it.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e778485a64c1..313db1c43839 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2673,7 +2673,6 @@ static struct page *
 get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 						const struct alloc_context *ac)
 {
-	struct zonelist *zonelist = ac->zonelist;
 	struct zoneref *z;
 	struct page *page = NULL;
 	struct zone *zone;
@@ -2687,7 +2686,7 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 	 * Scan zonelist, looking for a zone with enough free.
 	 * See also __cpuset_node_allowed() comment in kernel/cpuset.c.
 	 */
-	for_each_zone_zonelist_nodemask(zone, z, zonelist, ac->high_zoneidx,
+	for_each_zone_zonelist_nodemask(zone, z, ac->zonelist, ac->high_zoneidx,
 								ac->nodemask) {
 		unsigned long mark;
 
-- 
2.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
