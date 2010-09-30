Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 80A1C6B0088
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 23:51:02 -0400 (EDT)
Received: by mail-iw0-f169.google.com with SMTP id 33so2614800iwn.14
        for <linux-mm@kvack.org>; Wed, 29 Sep 2010 20:51:01 -0700 (PDT)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH 12/12] vmstat: include compaction.h when CONFIG_COMPACTION
Date: Thu, 30 Sep 2010 12:50:21 +0900
Message-Id: <1285818621-29890-13-git-send-email-namhyung@gmail.com>
In-Reply-To: <1285818621-29890-1-git-send-email-namhyung@gmail.com>
References: <1285818621-29890-1-git-send-email-namhyung@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This removes following warning from sparse:

 mm/vmstat.c:466:5: warning: symbol 'fragmentation_index' was not declared. Should it be static?

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
---
 mm/vmstat.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 355a9e6..30054ea 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -394,6 +394,8 @@ void zone_statistics(struct zone *preferred_zone, struct zone *z)
 #endif
 
 #ifdef CONFIG_COMPACTION
+#include <linux/compaction.h>
+
 struct contig_page_info {
 	unsigned long free_pages;
 	unsigned long free_blocks_total;
-- 
1.7.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
