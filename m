Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id E1E136B005A
	for <linux-mm@kvack.org>; Sun,  8 Jan 2012 09:05:46 -0500 (EST)
Received: by iacb35 with SMTP id b35so6606682iac.14
        for <linux-mm@kvack.org>; Sun, 08 Jan 2012 06:05:46 -0800 (PST)
From: Huang Shijie <shijie8@gmail.com>
Subject: [PATCH] mm/page_alloc.c : fix the typo of __zone_watermark_ok()
Date: Sun,  8 Jan 2012 22:06:09 -0500
Message-Id: <1326078369-2814-1-git-send-email-shijie8@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mgorman@suse.de, linux-mm@kvack.org, Huang Shijie <shijie8@gmail.com>

The current code does keep the same meaning as the original code.
The patch fixes it.

Signed-off-by: Huang Shijie <shijie8@gmail.com>
---
 mm/page_alloc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index bdc804c..63f9026 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1435,7 +1435,7 @@ static bool __zone_watermark_ok(struct zone *z, int order, unsigned long mark,
 	long min = mark;
 	int o;
 
-	free_pages -= (1 << order) + 1;
+	free_pages -= (1 << order) - 1;
 	if (alloc_flags & ALLOC_HIGH)
 		min -= min / 2;
 	if (alloc_flags & ALLOC_HARDER)
-- 
1.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
