Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 90A206B0037
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 23:53:39 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id w10so2512404pde.17
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 20:53:39 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id xr1si8059245pbb.104.2014.06.19.20.53.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 19 Jun 2014 20:53:38 -0700 (PDT)
Message-ID: <53A3B02D.5080703@huawei.com>
Date: Fri, 20 Jun 2014 11:53:17 +0800
From: Qiang Huang <h.huangqiang@huawei.com>
MIME-Version: 1.0
Subject: [PATCH] mm: update comments for get/set_pfnblock_flags_mask
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, mgorman@suse.de
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

These two functions changed many times, and comments are out of data
for a long time. Though it's minor, better update it.

Signed-off-by: Qiang Huang <h.huangqiang@huawei.com>
---
 mm/page_alloc.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4f59fa2..8221366 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6034,10 +6034,11 @@ static inline int pfn_to_bitidx(struct zone *zone, unsigned long pfn)
 }

 /**
- * get_pageblock_flags_group - Return the requested group of flags for the pageblock_nr_pages block of pages
+ * get_pfnblock_flags_mask - Return the requested group of flags for the pageblock_nr_pages block of pages
  * @page: The page within the block of interest
- * @start_bitidx: The first bit of interest to retrieve
+ * @pfn: Page Number of the page
  * @end_bitidx: The last bit of interest
+ * @mask: The mask for flags
  * returns pageblock_bits flags
  */
 unsigned long get_pfnblock_flags_mask(struct page *page, unsigned long pfn,
@@ -6063,9 +6064,10 @@ unsigned long get_pfnblock_flags_mask(struct page *page, unsigned long pfn,
 /**
  * set_pfnblock_flags_mask - Set the requested group of flags for a pageblock_nr_pages block of pages
  * @page: The page within the block of interest
- * @start_bitidx: The first bit of interest
- * @end_bitidx: The last bit of interest
  * @flags: The flags to set
+ * @pfn: Page Number of the page
+ * @end_bitidx: The last bit of interest
+ * @mask: The mask for flags
  */
 void set_pfnblock_flags_mask(struct page *page, unsigned long flags,
 					unsigned long pfn,
-- 
1.8.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
