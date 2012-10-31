Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 0A37E6B0068
	for <linux-mm@kvack.org>; Wed, 31 Oct 2012 12:59:10 -0400 (EDT)
Received: by mail-da0-f41.google.com with SMTP id i14so802019dad.14
        for <linux-mm@kvack.org>; Wed, 31 Oct 2012 09:59:10 -0700 (PDT)
From: Joonsoo Kim <js1304@gmail.com>
Subject: [PATCH v2 1/5] mm, highmem: use PKMAP_NR() to calculate an index of pkmap
Date: Thu,  1 Nov 2012 01:56:33 +0900
Message-Id: <1351702597-10795-2-git-send-email-js1304@gmail.com>
In-Reply-To: <1351702597-10795-1-git-send-email-js1304@gmail.com>
References: <Yes>
 <1351702597-10795-1-git-send-email-js1304@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Peter Zijlstra <a.p.zijlstra@chello.nl>

To calculate an index of pkmap, using PKMAP_NR() is more understandable
and maintainable, So change it.

Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Joonsoo Kim <js1304@gmail.com>
Reviewed-by: Minchan Kim <minchan@kernel.org>

diff --git a/mm/highmem.c b/mm/highmem.c
index d517cd1..b3b3d68 100644
--- a/mm/highmem.c
+++ b/mm/highmem.c
@@ -99,7 +99,7 @@ struct page *kmap_to_page(void *vaddr)
 	unsigned long addr = (unsigned long)vaddr;
 
 	if (addr >= PKMAP_ADDR(0) && addr <= PKMAP_ADDR(LAST_PKMAP)) {
-		int i = (addr - PKMAP_ADDR(0)) >> PAGE_SHIFT;
+		int i = PKMAP_NR(addr);
 		return pte_page(pkmap_page_table[i]);
 	}
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
