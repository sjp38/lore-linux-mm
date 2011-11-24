Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7996E6B00A0
	for <linux-mm@kvack.org>; Wed, 23 Nov 2011 21:58:09 -0500 (EST)
Received: by ghrr17 with SMTP id r17so2729256ghr.14
        for <linux-mm@kvack.org>; Wed, 23 Nov 2011 18:58:06 -0800 (PST)
Message-ID: <4ECDB2B2.2000206@gmail.com>
Date: Thu, 24 Nov 2011 10:57:54 +0800
From: Wang Sheng-Hui <shhuiw@gmail.com>
MIME-Version: 1.0
Subject: [PATCH] cleanup comment in include/linux/compaction.h for defer_compaction
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mel@csn.ul.ie, linux-mm@kvack.org, linux-kernel@vger.kernel.org

No compact_defer_limit is found in kernel source code.
Per the code implementation, compact_defer_limit should be
zone->compact_defer_shift. Cleanup the comment.

Signed-off-by: Wang Sheng-Hui <shhuiw@gmail.com>
---
 include/linux/compaction.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index cc9f7a4..b297a9c 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -32,8 +32,8 @@ extern unsigned long compact_zone_order(struct zone *zone, int order,
 
 /*
  * Compaction is deferred when compaction fails to result in a page
- * allocation success. 1 << compact_defer_limit compactions are skipped up
- * to a limit of 1 << COMPACT_MAX_DEFER_SHIFT
+ * allocation success. 1 << zone->compact_defer_shift compactions are
+ * skipped up to a limit of 1 << COMPACT_MAX_DEFER_SHIFT
  */
 static inline void defer_compaction(struct zone *zone)
 {
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
