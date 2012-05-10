Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 34C6D6B00F4
	for <linux-mm@kvack.org>; Thu, 10 May 2012 11:33:49 -0400 (EDT)
Received: by dakp5 with SMTP id p5so2565828dak.14
        for <linux-mm@kvack.org>; Thu, 10 May 2012 08:33:48 -0700 (PDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] cma: fix migration mode
Date: Fri, 11 May 2012 00:33:23 +0900
Message-Id: <1336664003-5031-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>

__alloc_contig_migrate_range calls migrate_pages with wrong argument
for migrate_mode. Fix it.

Cc: Marek Szyprowski <m.szyprowski@samsung.com>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 mm/page_alloc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4d926f1..9febc62 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5689,7 +5689,7 @@ static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
 
 		ret = migrate_pages(&cc.migratepages,
 				    __alloc_contig_migrate_alloc,
-				    0, false, true);
+				    0, false, MIGRATE_SYNC);
 	}
 
 	putback_lru_pages(&cc.migratepages);
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
