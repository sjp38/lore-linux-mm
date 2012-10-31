Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 69DDB6B0072
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 12:59:22 -0400 (EDT)
Received: by mail-da0-f41.google.com with SMTP id i14so802019dad.14
        for <linux-mm@kvack.org>; Wed, 31 Oct 2012 09:59:22 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH v2 5/5] mm, highmem: get virtual address of the page using PKMAP_ADDR()
Date: Thu,  1 Nov 2012 01:56:37 +0900
Message-Id: <1351702597-10795-6-git-send-email-js1304@gmail.com>
In-Reply-To: <1351702597-10795-1-git-send-email-js1304@gmail.com>
References: <Yes>
 <1351702597-10795-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Peter Zijlstra <a.p.zijlstra@chello.nl>

In flush_all_zero_pkmaps(), we have an index of the pkmap associated the page.
Using this index, we can simply get virtual address of the page.
So change it.

Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Joonsoo Kim <js1304@gmail.com>
Reviewed-by: Minchan Kim <minchan@kernel.org>

diff --git a/mm/highmem.c b/mm/highmem.c
index b365f7b..675ec97 100644
--- a/mm/highmem.c
+++ b/mm/highmem.c
@@ -137,8 +137,7 @@ static unsigned int flush_all_zero_pkmaps(void)
 		 * So no dangers, even with speculative execution.
 		 */
 		page = pte_page(pkmap_page_table[i]);
-		pte_clear(&init_mm, (unsigned long)page_address(page),
-			  &pkmap_page_table[i]);
+		pte_clear(&init_mm, PKMAP_ADDR(i), &pkmap_page_table[i]);
 
 		set_page_address(page, NULL);
 		if (index == PKMAP_INVALID_INDEX)
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
