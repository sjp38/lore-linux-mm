Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 03F736B006C
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 02:40:43 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id fp1so14730934pdb.10
        for <linux-mm@kvack.org>; Wed, 14 Jan 2015 23:40:42 -0800 (PST)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id ou2si747381pbb.214.2015.01.14.23.40.39
        for <linux-mm@kvack.org>;
        Wed, 14 Jan 2015 23:40:41 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 1/5] mm/compaction: change tracepoint format from decimal to hexadecimal
Date: Thu, 15 Jan 2015 16:41:09 +0900
Message-Id: <1421307673-24084-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

To check the range that compaction is working, tracepoint print
start/end pfn of zone and start pfn of both scanner with decimal format.
Since we manage all pages in order of 2 and it is well represented by
hexadecimal, this patch change the tracepoint format from decimal to
hexadecimal. This would improve readability. For example, it makes us
easily notice whether current scanner try to compact previously
attempted pageblock or not.

Acked-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/trace/events/compaction.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/trace/events/compaction.h b/include/trace/events/compaction.h
index c6814b9..1337d9e 100644
--- a/include/trace/events/compaction.h
+++ b/include/trace/events/compaction.h
@@ -104,7 +104,7 @@ TRACE_EVENT(mm_compaction_begin,
 		__entry->zone_end = zone_end;
 	),
 
-	TP_printk("zone_start=%lu migrate_start=%lu free_start=%lu zone_end=%lu",
+	TP_printk("zone_start=0x%lx migrate_start=0x%lx free_start=0x%lx zone_end=0x%lx",
 		__entry->zone_start,
 		__entry->migrate_start,
 		__entry->free_start,
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
