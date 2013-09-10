Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 3D6866B0031
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 00:03:31 -0400 (EDT)
Received: by mail-la0-f43.google.com with SMTP id ep20so5604561lab.2
        for <linux-mm@kvack.org>; Mon, 09 Sep 2013 21:03:29 -0700 (PDT)
From: Vladimir Murzin <murzin.v@gmail.com>
Subject: [PATCH] mm: fix section mismatch warning in set_pageblock_order
Date: Tue, 10 Sep 2013 12:03:01 +0400
Message-Id: <1378800181-4611-1-git-send-email-murzin.v@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mgorman@suse.de, Vladimir Murzin <murzin.v@gmail.com>

While cross-building for PPC I've got

WARNING: mm/built-in.o(.meminit.text+0xeb0): Section mismatch in reference
from the function .free_area_init_core.isra.47() to the function
.init.text:.set_pageblock_order() The function __meminit
.free_area_init_core.isra.47() references a function __init
.set_pageblock_order(). If .set_pageblock_order is only used by
.free_area_init_core.isra.47 then annotate .set_pageblock_order with a
matching annotation.

Annotation for free_area_init_core depends on CONFIG_SPARSEMEM. Use the same
annotation (__paginginit) for set_pageblock_order.

Signed-off-by: Vladimir Murzin <murzin.v@gmail.com>
---
 mm/page_alloc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c2b59db..818e0b4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4586,7 +4586,7 @@ static inline void setup_usemap(struct pglist_data *pgdat, struct zone *zone,
 #ifdef CONFIG_HUGETLB_PAGE_SIZE_VARIABLE
 
 /* Initialise the number of pages represented by NR_PAGEBLOCK_BITS */
-void __init set_pageblock_order(void)
+void __paginginit set_pageblock_order(void)
 {
 	unsigned int order;
 
@@ -4614,7 +4614,7 @@ void __init set_pageblock_order(void)
  * include/linux/pageblock-flags.h for the values of pageblock_order based on
  * the kernel config
  */
-void __init set_pageblock_order(void)
+void __paginginit set_pageblock_order(void)
 {
 }
 
-- 
1.8.1.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
