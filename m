Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 32D4C6B004D
	for <linux-mm@kvack.org>; Sat, 31 Dec 2011 04:08:49 -0500 (EST)
From: Huang Shijie <b32955@freescale.com>
Subject: [PATCH v2] mm/compaction : fix the wrong return value for isolate_migratepages()
Date: Sat, 31 Dec 2011 17:09:45 +0800
Message-ID: <1325322585-16216-1-git-send-email-b32955@freescale.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mgorman@suse.de, linux-mm@kvack.org, shijie8@gmail.com, Huang Shijie <b32955@freescale.com>

When we do not get any migrate page, we should return ISOLATE_NONE.

Signed-off-by: Huang Shijie <b32955@freescale.com>
---
 mm/compaction.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 0f12cc9..3db8630 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -376,7 +376,7 @@ static isolate_migrate_t isolate_migratepages(struct zone *zone,
 
 	trace_mm_compaction_isolate_migratepages(nr_scanned, nr_isolated);
 
-	return ISOLATE_SUCCESS;
+	return (cc->nr_migratepages == 0) ? ISOLATE_NONE : ISOLATE_SUCCESS;
 }
 
 /*
-- 
1.7.3.2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
