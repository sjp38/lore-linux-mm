Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id EA1F46B006E
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 19:26:44 -0500 (EST)
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Tue, 15 Jan 2013 17:26:44 -0700
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 1460319D8072
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 17:25:48 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0G0PlGC110060
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 17:25:47 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0G0Plgs031531
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 17:25:47 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 10/17] mm/vmstat: use zone_end_pfn() instead of opencoding
Date: Tue, 15 Jan 2013 16:24:47 -0800
Message-Id: <1358295894-24167-11-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1358295894-24167-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1358295894-24167-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

In vmstat, use zone_end_pfn() instead of an opencoded version.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/vmstat.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 9800306..ca99641 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -890,7 +890,7 @@ static void pagetypeinfo_showblockcount_print(struct seq_file *m,
 	int mtype;
 	unsigned long pfn;
 	unsigned long start_pfn = zone->zone_start_pfn;
-	unsigned long end_pfn = start_pfn + zone->spanned_pages;
+	unsigned long end_pfn = zone_end_pfn(zone);
 	unsigned long count[MIGRATE_TYPES] = { 0, };
 
 	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
-- 
1.8.0.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
