Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id B9D6B6B0038
	for <linux-mm@kvack.org>; Mon,  2 Mar 2015 09:30:15 -0500 (EST)
Received: by igbhn18 with SMTP id hn18so17514877igb.2
        for <linux-mm@kvack.org>; Mon, 02 Mar 2015 06:30:15 -0800 (PST)
Received: from m12-18.163.com (m12-18.163.com. [220.181.12.18])
        by mx.google.com with ESMTP id m10si11324785ice.39.2015.03.02.06.30.14
        for <linux-mm@kvack.org>;
        Mon, 02 Mar 2015 06:30:15 -0800 (PST)
From: Yaowei Bai <bywxiaobai@163.com>
Subject: [PATCH 1/2] mm/page_alloc.c: Add '(' and ')' in comment
Date: Mon,  2 Mar 2015 22:26:00 +0800
Message-Id: <1425306361-3446-1-git-send-email-bywxiaobai@163.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, hannes@cmpxchg.org, riel@redhat.com, iamjoonsoo.kim@lge.com, rientjes@google.com, sasha.levin@oracle.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Add parentheses to make the two deltas consistent.

Signed-off-by: Yaowei Bai <bywxiaobai@163.com>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7abfa70..12c96ad 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5715,7 +5715,7 @@ static void __setup_per_zone_wmarks(void)
 			 * need highmem pages, so cap pages_min to a small
 			 * value here.
 			 *
-			 * The WMARK_HIGH-WMARK_LOW and (WMARK_LOW-WMARK_MIN)
+			 * The (WMARK_HIGH-WMARK_LOW) and (WMARK_LOW-WMARK_MIN)
 			 * deltas controls asynch page reclaim, and so should
 			 * not be capped for highmem.
 			 */
-- 
1.9.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
