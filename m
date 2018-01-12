Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2368C6B0253
	for <linux-mm@kvack.org>; Fri, 12 Jan 2018 18:56:51 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id e9so3766530oib.10
        for <linux-mm@kvack.org>; Fri, 12 Jan 2018 15:56:51 -0800 (PST)
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTP id z90si433925ota.153.2018.01.12.15.56.49
        for <linux-mm@kvack.org>;
        Fri, 12 Jan 2018 15:56:50 -0800 (PST)
From: Yang Shi <yang.shi@linux.alibaba.com>
Subject: [PATCH] mm/compaction: fix the comment for try_to_compact_pages
Date: Sat, 13 Jan 2018 07:55:36 +0800
Message-Id: <1515801336-20611-1-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: yang.shi@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.com>

"mode" argument is not used by try_to_compact_pages() and sub functions
anymore, it has been replaced by "prio". Fix the comment to explain the
use of "prio" argument.

Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Michal Hocko <mhocko@suse.com>
Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
---
 mm/compaction.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 10cd757..2c8999d 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -1738,7 +1738,7 @@ static enum compact_result compact_zone_order(struct zone *zone, int order,
  * @order: The order of the current allocation
  * @alloc_flags: The allocation flags of the current allocation
  * @ac: The context of current allocation
- * @mode: The migration mode for async, sync light, or sync migration
+ * @prio: Determines how hard direct compaction should try to succeed
  *
  * This is the main entry point for direct page compaction.
  */
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
