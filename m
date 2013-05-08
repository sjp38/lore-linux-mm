Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 7ADE46B0135
	for <linux-mm@kvack.org>; Wed,  8 May 2013 12:03:15 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 07/22] mm: page allocator: Do not lookup the pageblock migratetype during allocation
Date: Wed,  8 May 2013 17:02:52 +0100
Message-Id: <1368028987-8369-8-git-send-email-mgorman@suse.de>
In-Reply-To: <1368028987-8369-1-git-send-email-mgorman@suse.de>
References: <1368028987-8369-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave@sr71.net>, Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

The pageblock migrate type is checked during allocation in case it's CMA
but using get_freepage_migratetype() should be sufficient as the
magazines would have been drained prior to a CMA allocation attempt.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f74e16f..8867937 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1523,7 +1523,7 @@ again:
 		if (!page)
 			goto failed;
 		__mod_zone_freepage_state(zone, -(1 << order),
-					  get_pageblock_migratetype(page));
+					  get_freepage_migratetype(page));
 	}
 
 	__count_zone_vm_events(PGALLOC, zone, 1 << order);
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
