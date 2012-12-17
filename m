Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 0C8716B005A
	for <linux-mm@kvack.org>; Mon, 17 Dec 2012 16:23:11 -0500 (EST)
From: Srinivas Pandruvada <srinivas.pandruvada@linux.intel.com>
Subject: [PATCH] CMA: call to putback_lru_pages
Date: Mon, 17 Dec 2012 13:25:04 -0800
Message-Id: <1355779504-30798-1-git-send-email-srinivas.pandruvada@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Srinivas Pandruvada <srinivas.pandruvada@linux.intel.com>

As per documentation and other places calling putback_lru_pages,
on error only, except for CMA. I am not sure this is a problem
for CMA or not.

Signed-off-by: Srinivas Pandruvada <srinivas.pandruvada@linux.intel.com>
---
 mm/page_alloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 83637df..5a887bf 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5802,8 +5802,8 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
 				    alloc_migrate_target,
 				    0, false, MIGRATE_SYNC);
 	}
-
-	putback_movable_pages(&cc->migratepages);
+	if (ret < 0)
+		putback_movable_pages(&cc->migratepages);
 	return ret > 0 ? 0 : ret;
 }
 
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
