Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 5E44C6B005D
	for <linux-mm@kvack.org>; Mon, 12 Nov 2012 03:45:11 -0500 (EST)
From: Thierry Reding <thierry.reding@avionic-design.de>
Subject: [PATCH] mm: Remove unused variable in alloc_contig_range()
Date: Mon, 12 Nov 2012 09:45:06 +0100
Message-Id: <1352709906-10749-1-git-send-email-thierry.reding@avionic-design.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Commit 872ca38f7afd9566bf2f88b95616f7ab71b50064 removed the last
reference to this variable but not the variable itself.

Signed-off-by: Thierry Reding <thierry.reding@avionic-design.de>
---
 mm/page_alloc.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6b990cb..71933dd 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5822,7 +5822,6 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
 int alloc_contig_range(unsigned long start, unsigned long end,
 		       unsigned migratetype)
 {
-	struct zone *zone = page_zone(pfn_to_page(start));
 	unsigned long outer_start, outer_end;
 	int ret = 0, order;
 
-- 
1.8.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
