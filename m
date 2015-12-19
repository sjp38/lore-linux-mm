Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id ECC3C4402ED
	for <linux-mm@kvack.org>; Sat, 19 Dec 2015 04:10:03 -0500 (EST)
Received: by mail-ob0-f174.google.com with SMTP id ba1so3425267obb.3
        for <linux-mm@kvack.org>; Sat, 19 Dec 2015 01:10:03 -0800 (PST)
Received: from m50-135.163.com (m50-135.163.com. [123.125.50.135])
        by mx.google.com with ESMTP id b202si620052oig.100.2015.12.19.01.09.11
        for <linux-mm@kvack.org>;
        Sat, 19 Dec 2015 01:10:03 -0800 (PST)
From: Geliang Tang <geliangtang@163.com>
Subject: [PATCH] mm: move lru_to_page to mm_inline.h
Date: Sat, 19 Dec 2015 17:08:27 +0800
Message-Id: <db243314728321f435fb82dc2b5d99d98af409e2.1450515627.git.geliangtang@163.com>
In-Reply-To: <56744194.80809@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Jens Axboe <axboe@fb.com>, Tejun Heo <tj@kernel.org>
Cc: Geliang Tang <geliangtang@163.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Move lru_to_page() from internal.h to mm_inline.h.

Signed-off-by: Geliang Tang <geliangtang@163.com>
---
 include/linux/mm_inline.h | 2 ++
 mm/internal.h             | 2 --
 mm/readahead.c            | 1 +
 3 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index cf55945..712e8c3 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -100,4 +100,6 @@ static __always_inline enum lru_list page_lru(struct page *page)
 	return lru;
 }
 
+#define lru_to_page(head) (list_entry((head)->prev, struct page, lru))
+
 #endif
diff --git a/mm/internal.h b/mm/internal.h
index ca49922..5d8ec89 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -87,8 +87,6 @@ extern int isolate_lru_page(struct page *page);
 extern void putback_lru_page(struct page *page);
 extern bool zone_reclaimable(struct zone *zone);
 
-#define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
-
 /*
  * in mm/rmap.c:
  */
diff --git a/mm/readahead.c b/mm/readahead.c
index 0aff760..20e58e8 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -17,6 +17,7 @@
 #include <linux/pagemap.h>
 #include <linux/syscalls.h>
 #include <linux/file.h>
+#include <linux/mm_inline.h>
 
 #include "internal.h"
 
-- 
2.5.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
