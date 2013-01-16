Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 4E7006B0080
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 19:26:17 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Tue, 15 Jan 2013 19:26:16 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 909146E803F
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 19:25:58 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0G0Pxo9307444
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 19:25:59 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0G0Pws5000971
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 22:25:59 -0200
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 17/17] mm/compaction: use zone_end_pfn()
Date: Tue, 15 Jan 2013 16:24:54 -0800
Message-Id: <1358295894-24167-18-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1358295894-24167-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1358295894-24167-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

Switch to using zone_end_pfn from open coding.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/compaction.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 1b52528..ea66be3 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -85,7 +85,7 @@ static inline bool isolation_suitable(struct compact_control *cc,
 static void __reset_isolation_suitable(struct zone *zone)
 {
 	unsigned long start_pfn = zone->zone_start_pfn;
-	unsigned long end_pfn = zone->zone_start_pfn + zone->spanned_pages;
+	unsigned long end_pfn = zone_end_pfn(zone);
 	unsigned long pfn;
 
 	zone->compact_cached_migrate_pfn = start_pfn;
@@ -663,7 +663,7 @@ static void isolate_freepages(struct zone *zone,
 	 */
 	high_pfn = min(low_pfn, pfn);
 
-	z_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
+	z_end_pfn = zone_end_pfn(zone);
 
 	/*
 	 * Isolate free pages until enough are available to migrate the
@@ -920,7 +920,7 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 {
 	int ret;
 	unsigned long start_pfn = zone->zone_start_pfn;
-	unsigned long end_pfn = zone->zone_start_pfn + zone->spanned_pages;
+	unsigned long end_pfn = zone_end_pfn(zone);
 
 	ret = compaction_suitable(zone, cc->order);
 	switch (ret) {
-- 
1.8.0.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
