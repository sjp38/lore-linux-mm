Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id 83C926B0031
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 12:48:52 -0500 (EST)
Received: by mail-ee0-f49.google.com with SMTP id c41so626730eek.8
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 09:48:52 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id m49si22240886eeg.220.2013.11.22.09.48.51
        for <linux-mm@kvack.org>;
        Fri, 22 Nov 2013 09:48:51 -0800 (PST)
Date: Fri, 22 Nov 2013 12:01:06 -0500
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: [PATCH] mmzone.h: constify some zone access functions
Message-ID: <20131122120106.4c372847@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, dave.hansen@intel.com

Signed-off-by: Luiz capitulino <lcapitulino@redhat.com>
---
 include/linux/mmzone.h | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index bd791e4..5e202d6 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -560,12 +560,12 @@ static inline bool zone_spans_pfn(const struct zone *zone, unsigned long pfn)
 	return zone->zone_start_pfn <= pfn && pfn < zone_end_pfn(zone);
 }
 
-static inline bool zone_is_initialized(struct zone *zone)
+static inline bool zone_is_initialized(const struct zone *zone)
 {
 	return !!zone->wait_table;
 }
 
-static inline bool zone_is_empty(struct zone *zone)
+static inline bool zone_is_empty(const struct zone *zone)
 {
 	return zone->spanned_pages == 0;
 }
@@ -843,7 +843,7 @@ unsigned long __init node_memmap_size_bytes(int, unsigned long, unsigned long);
  */
 #define zone_idx(zone)		((zone) - (zone)->zone_pgdat->node_zones)
 
-static inline int populated_zone(struct zone *zone)
+static inline int populated_zone(const struct zone *zone)
 {
 	return (!!zone->present_pages);
 }
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
