Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 6D2676B0033
	for <linux-mm@kvack.org>; Fri, 14 Jun 2013 08:39:23 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id xa12so534387pbc.11
        for <linux-mm@kvack.org>; Fri, 14 Jun 2013 05:39:22 -0700 (PDT)
Message-ID: <51BB0EF1.7040303@gmail.com>
Date: Fri, 14 Jun 2013 20:39:13 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: [PATCH] mm: Remove unused functions is_{normal_idx, normal, dma32,
 dma}
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

These functions are nowhere used, so remove them.

Signed-off-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 include/linux/mmzone.h |   28 ----------------------------
 1 files changed, 0 insertions(+), 28 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 5c76737..32f0105 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -843,11 +843,6 @@ static inline int is_highmem_idx(enum zone_type idx)
 #endif
 }
 
-static inline int is_normal_idx(enum zone_type idx)
-{
-	return (idx == ZONE_NORMAL);
-}
-
 /**
  * is_highmem - helper function to quickly check if a struct zone is a 
  *              highmem zone or not.  This is an attempt to keep references
@@ -866,29 +861,6 @@ static inline int is_highmem(struct zone *zone)
 #endif
 }
 
-static inline int is_normal(struct zone *zone)
-{
-	return zone == zone->zone_pgdat->node_zones + ZONE_NORMAL;
-}
-
-static inline int is_dma32(struct zone *zone)
-{
-#ifdef CONFIG_ZONE_DMA32
-	return zone == zone->zone_pgdat->node_zones + ZONE_DMA32;
-#else
-	return 0;
-#endif
-}
-
-static inline int is_dma(struct zone *zone)
-{
-#ifdef CONFIG_ZONE_DMA
-	return zone == zone->zone_pgdat->node_zones + ZONE_DMA;
-#else
-	return 0;
-#endif
-}
-
 /* These two functions are used to setup the per zone pages min values */
 struct ctl_table;
 int min_free_kbytes_sysctl_handler(struct ctl_table *, int,
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
