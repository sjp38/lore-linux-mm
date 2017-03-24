Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2A4986B0337
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 10:11:22 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 79so6177042pgf.2
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 07:11:22 -0700 (PDT)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id u29si3030844pgn.124.2017.03.24.07.11.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 07:11:21 -0700 (PDT)
Received: by mail-pg0-x241.google.com with SMTP id 79so724017pgf.0
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 07:11:21 -0700 (PDT)
From: Geliang Tang <geliangtang@gmail.com>
Subject: [PATCH] mm/page_alloc: use nth_page helper
Date: Fri, 24 Mar 2017 22:10:50 +0800
Message-Id: <b75be84c34466eb063bd44ee1ff7f2bf085002b2.1490323567.git.geliangtang@gmail.com>
In-Reply-To: <ab50f7fbf9826ac7275f0513ca04bf1073b41a36.1490323750.git.geliangtang@gmail.com>
References: <ab50f7fbf9826ac7275f0513ca04bf1073b41a36.1490323750.git.geliangtang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Geliang Tang <geliangtang@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Use nth_page() helper instead of page_to_pfn() and pfn_to_page() to
simplify the code.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 mm/page_alloc.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f749b7f..3354f56 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2511,9 +2511,8 @@ void mark_free_pages(struct zone *zone)
 				&zone->free_area[order].free_list[t], lru) {
 			unsigned long i;
 
-			pfn = page_to_pfn(page);
 			for (i = 0; i < (1UL << order); i++)
-				swsusp_set_page_free(pfn_to_page(pfn + i));
+				swsusp_set_page_free(nth_page(page, i));
 		}
 	}
 	spin_unlock_irqrestore(&zone->lock, flags);
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
