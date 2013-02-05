Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 45EA96B0009
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 12:11:54 -0500 (EST)
Received: by mail-da0-f42.google.com with SMTP id z17so147917dal.15
        for <linux-mm@kvack.org>; Tue, 05 Feb 2013 09:11:53 -0800 (PST)
Message-ID: <51113D4F.6050307@gmail.com>
Date: Wed, 06 Feb 2013 01:11:43 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: [PATCH 1/3] mm: rename nr_free_zone_pages to nr_free_zone_high_pages
References: <51113CE3.5090000@gmail.com>
In-Reply-To: <51113CE3.5090000@gmail.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Linux MM <linux-mm@kvack.org>, mgorman@suse.de, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, m.szyprowski@samsung.com
Cc: linux-kernel@vger.kernel.org, zhangyanfei@cn.fujitsu.com

From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

This function actually counts present_pages - pages_high, so rename
it to a reasonable name.

Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 mm/page_alloc.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index df2022f..4aea19e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2785,7 +2785,7 @@ void free_pages_exact(void *virt, size_t size)
 }
 EXPORT_SYMBOL(free_pages_exact);
 
-static unsigned int nr_free_zone_pages(int offset)
+static unsigned int nr_free_zone_high_pages(int offset)
 {
 	struct zoneref *z;
 	struct zone *zone;
@@ -2810,7 +2810,7 @@ static unsigned int nr_free_zone_pages(int offset)
  */
 unsigned int nr_free_buffer_pages(void)
 {
-	return nr_free_zone_pages(gfp_zone(GFP_USER));
+	return nr_free_zone_high_pages(gfp_zone(GFP_USER));
 }
 EXPORT_SYMBOL_GPL(nr_free_buffer_pages);
 
@@ -2819,7 +2819,7 @@ EXPORT_SYMBOL_GPL(nr_free_buffer_pages);
  */
 unsigned int nr_free_pagecache_pages(void)
 {
-	return nr_free_zone_pages(gfp_zone(GFP_HIGHUSER_MOVABLE));
+	return nr_free_zone_high_pages(gfp_zone(GFP_HIGHUSER_MOVABLE));
 }
 
 static inline void show_node(struct zone *zone)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
