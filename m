Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id A299E6B0074
	for <linux-mm@kvack.org>; Sun, 28 Oct 2012 15:15:19 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so3210249pad.14
        for <linux-mm@kvack.org>; Sun, 28 Oct 2012 12:15:19 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH 5/5] mm, highmem: get virtual address of the page using PKMAP_ADDR()
Date: Mon, 29 Oct 2012 04:12:56 +0900
Message-Id: <1351451576-2611-6-git-send-email-js1304@gmail.com>
In-Reply-To: <1351451576-2611-1-git-send-email-js1304@gmail.com>
References: <Yes>
 <1351451576-2611-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

In flush_all_zero_pkmaps(), we have an index of the pkmap associated the page.
Using this index, we can simply get virtual address of the page.
So change it.

Signed-off-by: Joonsoo Kim <js1304@gmail.com>

diff --git a/mm/highmem.c b/mm/highmem.c
index 65beb9a..1417f4f 100644
--- a/mm/highmem.c
+++ b/mm/highmem.c
@@ -137,8 +137,7 @@ static int flush_all_zero_pkmaps(void)
 		 * So no dangers, even with speculative execution.
 		 */
 		page = pte_page(pkmap_page_table[i]);
-		pte_clear(&init_mm, (unsigned long)page_address(page),
-			  &pkmap_page_table[i]);
+		pte_clear(&init_mm, PKMAP_ADDR(i), &pkmap_page_table[i]);
 
 		set_page_address(page, NULL);
 		index = i;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
