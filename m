Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id EAA0C6B0253
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 03:17:18 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id n6so9943189pfg.19
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 00:17:18 -0800 (PST)
Received: from EUR02-HE1-obe.outbound.protection.outlook.com (mail-eopbgr10094.outbound.protection.outlook.com. [40.107.1.94])
        by mx.google.com with ESMTPS id q7si10068646plk.225.2018.01.09.00.17.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 09 Jan 2018 00:17:17 -0800 (PST)
From: Shile Zhang <zhangshile@gmail.com>
Subject: [PATCH] mm/page_alloc.c: fix typos in comments
Date: Tue, 9 Jan 2018 16:16:14 +0800
Message-ID: <1515485774-4768-1-git-send-email-zhangshile@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Shile Zhang <zhangshile@gmail.com>

Signed-off-by: Shile Zhang <zhangshile@gmail.com>
---
 mm/page_alloc.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 76c9688..bfd5f99 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -293,7 +293,7 @@ int page_group_by_mobility_disabled __read_mostly;
 #ifdef CONFIG_DEFERRED_STRUCT_PAGE_INIT
 
 /*
- * Determine how many pages need to be initialized durig early boot
+ * Determine how many pages need to be initialized during early boot
  * (non-deferred initialization).
  * The value of first_deferred_pfn will be set later, once non-deferred pages
  * are initialized, but for now set it ULONG_MAX.
@@ -344,7 +344,7 @@ static inline bool update_defer_init(pg_data_t *pgdat,
 				unsigned long pfn, unsigned long zone_end,
 				unsigned long *nr_initialised)
 {
-	/* Always populate low zones for address-contrained allocations */
+	/* Always populate low zones for address-constrained allocations */
 	if (zone_end < pgdat_end_pfn(pgdat))
 		return true;
 	(*nr_initialised)++;
@@ -1502,7 +1502,7 @@ static unsigned long __init deferred_init_range(int nid, int zid,
 	 * performing it only once every pageblock_nr_pages.
 	 *
 	 * We do it in two loops: first we initialize struct page, than free to
-	 * buddy allocator, becuse while we are freeing pages we can access
+	 * buddy allocator, because while we are freeing pages we can access
 	 * pages that are ahead (computing buddy page in __free_one_page()).
 	 */
 	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
@@ -3391,7 +3391,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	if (gfp_mask & __GFP_THISNODE)
 		goto out;
 
-	/* Exhausted what can be done so it's blamo time */
+	/* Exhausted what can be done so it's blame time */
 	if (out_of_memory(&oc) || WARN_ON_ONCE(gfp_mask & __GFP_NOFAIL)) {
 		*did_some_progress = 1;
 
-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
