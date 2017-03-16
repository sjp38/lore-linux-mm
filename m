Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3C4BD6B03A4
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 22:01:13 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id e12so41748843ioj.0
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 19:01:13 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0084.hostedemail.com. [216.40.44.84])
        by mx.google.com with ESMTPS id u124si2015631itd.111.2017.03.15.19.01.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 19:01:12 -0700 (PDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 06/15] mm: page_alloc: Use unsigned int instead of unsigned
Date: Wed, 15 Mar 2017 19:00:03 -0700
Message-Id: <6608d7178089b48ca4d33cc134ffd86dcdfd0d5d.1489628477.git.joe@perches.com>
In-Reply-To: <cover.1489628477.git.joe@perches.com>
References: <cover.1489628477.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

It's what's generally desired.

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/page_alloc.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2933a8a11927..dca8904bbe2e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -467,7 +467,7 @@ void set_pageblock_migratetype(struct page *page, int migratetype)
 static int page_outside_zone_boundaries(struct zone *zone, struct page *page)
 {
 	int ret = 0;
-	unsigned seq;
+	unsigned int seq;
 	unsigned long pfn = page_to_pfn(page);
 	unsigned long sp, start_pfn;
 
@@ -1582,7 +1582,7 @@ void __init page_alloc_init_late(void)
 /* Free whole pageblock and set its migration type to MIGRATE_CMA. */
 void __init init_cma_reserved_pageblock(struct page *page)
 {
-	unsigned i = pageblock_nr_pages;
+	unsigned int i = pageblock_nr_pages;
 	struct page *p = page;
 
 	do {
@@ -3588,7 +3588,7 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
  * Returns true if a retry is viable or false to enter the oom path.
  */
 static inline bool
-should_reclaim_retry(gfp_t gfp_mask, unsigned order,
+should_reclaim_retry(gfp_t gfp_mask, unsigned int order,
 		     struct alloc_context *ac, int alloc_flags,
 		     bool did_some_progress, int *no_progress_loops)
 {
@@ -7508,7 +7508,7 @@ static int __alloc_contig_migrate_range(struct compact_control *cc,
  * need to be freed with free_contig_range().
  */
 int alloc_contig_range(unsigned long start, unsigned long end,
-		       unsigned migratetype, gfp_t gfp_mask)
+		       unsigned int migratetype, gfp_t gfp_mask)
 {
 	unsigned long outer_start, outer_end;
 	unsigned int order;
@@ -7632,7 +7632,7 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 	return ret;
 }
 
-void free_contig_range(unsigned long pfn, unsigned nr_pages)
+void free_contig_range(unsigned long pfn, unsigned int nr_pages)
 {
 	unsigned int count = 0;
 
@@ -7653,7 +7653,7 @@ void free_contig_range(unsigned long pfn, unsigned nr_pages)
  */
 void __meminit zone_pcp_update(struct zone *zone)
 {
-	unsigned cpu;
+	unsigned int cpu;
 
 	mutex_lock(&pcp_batch_high_lock);
 	for_each_possible_cpu(cpu)
-- 
2.10.0.rc2.1.g053435c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
