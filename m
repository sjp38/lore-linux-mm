Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id 6CFD16B0038
	for <linux-mm@kvack.org>; Sun, 27 Jul 2014 17:15:42 -0400 (EDT)
Received: by mail-wi0-f175.google.com with SMTP id ho1so3431810wib.2
        for <linux-mm@kvack.org>; Sun, 27 Jul 2014 14:15:41 -0700 (PDT)
Received: from casper.infradead.org (casper.infradead.org. [2001:770:15f::2])
        by mx.google.com with ESMTPS id l1si194005wif.13.2014.07.27.14.15.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Jul 2014 14:15:41 -0700 (PDT)
Message-ID: <53D56BF5.5030002@infradead.org>
Date: Sun, 27 Jul 2014 14:15:33 -0700
From: Randy Dunlap <rdunlap@infradead.org>
MIME-Version: 1.0
Subject: [PATCH] mm: fix page_alloc.c kernel-doc warnings
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>

From: Randy Dunlap <rdunlap@infradead.org>

Fix kernel-doc warnings and function name in mm/page_alloc.c:

Warning(..//mm/page_alloc.c:6074): No description found for parameter 'pfn'
Warning(..//mm/page_alloc.c:6074): No description found for parameter 'mask'
Warning(..//mm/page_alloc.c:6074): Excess function parameter 'start_bitidx' description in 'get_pfnblock_flags_mask'
Warning(..//mm/page_alloc.c:6102): No description found for parameter 'pfn'
Warning(..//mm/page_alloc.c:6102): No description found for parameter 'mask'
Warning(..//mm/page_alloc.c:6102): Excess function parameter 'start_bitidx' description in 'set_pfnblock_flags_mask'

Signed-off-by: Randy Dunlap <rdunlap@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>
---
 mm/page_alloc.c |   15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

Index: lnx-316-rc7/mm/page_alloc.c
===================================================================
--- lnx-316-rc7.orig/mm/page_alloc.c
+++ lnx-316-rc7/mm/page_alloc.c
@@ -6062,11 +6062,13 @@ static inline int pfn_to_bitidx(struct z
 }
 
 /**
- * get_pageblock_flags_group - Return the requested group of flags for the pageblock_nr_pages block of pages
+ * get_pfnblock_flags_mask - Return the requested group of flags for the pageblock_nr_pages block of pages
  * @page: The page within the block of interest
- * @start_bitidx: The first bit of interest to retrieve
- * @end_bitidx: The last bit of interest
- * returns pageblock_bits flags
+ * @pfn: The target page frame number
+ * @end_bitidx: The last bit of interest to retrieve
+ * @mask: mask of bits that the caller is interested in
+ *
+ * Return: pageblock_bits flags
  */
 unsigned long get_pfnblock_flags_mask(struct page *page, unsigned long pfn,
 					unsigned long end_bitidx,
@@ -6091,9 +6093,10 @@ unsigned long get_pfnblock_flags_mask(st
 /**
  * set_pfnblock_flags_mask - Set the requested group of flags for a pageblock_nr_pages block of pages
  * @page: The page within the block of interest
- * @start_bitidx: The first bit of interest
- * @end_bitidx: The last bit of interest
  * @flags: The flags to set
+ * @pfn: The target page frame number
+ * @end_bitidx: The last bit of interest
+ * @mask: mask of bits that the caller is interested in
  */
 void set_pfnblock_flags_mask(struct page *page, unsigned long flags,
 					unsigned long pfn,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
