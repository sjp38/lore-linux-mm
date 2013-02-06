Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id DD3AD6B0002
	for <linux-mm@kvack.org>; Wed,  6 Feb 2013 04:00:04 -0500 (EST)
Message-ID: <5112138C.7040902@cn.fujitsu.com>
Date: Wed, 06 Feb 2013 16:25:48 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH] mm: accurately document nr_free_*_pages functions with code
 comments
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, mgorman@suse.de, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com
Cc: Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

Functions nr_free_zone_pages, nr_free_buffer_pages and nr_free_pagecache_pages
are horribly badly named, so accurately document them with code comments
in case of the misuse of them.

Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 mm/page_alloc.c |   23 +++++++++++++++++++----
 1 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index df2022f..0790716 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2785,6 +2785,15 @@ void free_pages_exact(void *virt, size_t size)
 }
 EXPORT_SYMBOL(free_pages_exact);
 
+/**
+ * nr_free_zone_pages - get pages that is beyond high watermark
+ * @offset - The zone index of the highest zone
+ *
+ * The function counts pages which are beyond high watermark within
+ * all zones at or below a given zone index. For each zone, the
+ * amount of pages is calculated as:
+ *     present_pages - high_pages
+ */
 static unsigned int nr_free_zone_pages(int offset)
 {
 	struct zoneref *z;
@@ -2805,8 +2814,11 @@ static unsigned int nr_free_zone_pages(int offset)
 	return sum;
 }
 
-/*
- * Amount of free RAM allocatable within ZONE_DMA and ZONE_NORMAL
+/**
+ * nr_free_buffer_pages - get pages that is beyond high watermark
+ *
+ * The function counts pages which are beyond high watermark within
+ * ZONE_DMA and ZONE_NORMAL.
  */
 unsigned int nr_free_buffer_pages(void)
 {
@@ -2814,8 +2826,11 @@ unsigned int nr_free_buffer_pages(void)
 }
 EXPORT_SYMBOL_GPL(nr_free_buffer_pages);
 
-/*
- * Amount of free RAM allocatable within all zones
+/**
+ * nr_free_pagecache_pages - get pages that is beyond high watermark
+ *
+ * The function counts pages which are beyond high watermark within
+ * all zones.
  */
 unsigned int nr_free_pagecache_pages(void)
 {
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
