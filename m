Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id B51F26B0032
	for <linux-mm@kvack.org>; Mon, 22 Jul 2013 03:30:06 -0400 (EDT)
Message-ID: <51ECDF41.10808@asianux.com>
Date: Mon, 22 Jul 2013 15:29:05 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: [PATCH] mm/page_alloc.c: use '__paginginit' instead of '__init'
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, jiang.liu@huawei.com, minchan@kernel.org, cody@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

set_pageblock_order() may be called when memory hotplug, so need use
'__paginginit' instead of '__init'.

The related warning:

  The function __meminit .free_area_init_node() references
  a function __init .set_pageblock_order().
  If .set_pageblock_order is only used by .free_area_init_node then
  annotate .set_pageblock_order with a matching annotation.


Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 mm/page_alloc.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index b100255..4c58635 100644
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
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
