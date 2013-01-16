Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id B69CB6B0071
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 19:25:58 -0500 (EST)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Tue, 15 Jan 2013 17:25:57 -0700
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 541423E40045
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 17:25:48 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0G0PsON268596
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 17:25:54 -0700
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0G0S4S8004702
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 17:28:05 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 12/17] mm/memory_hotplug: use pgdat_end_pfn() instead of open coding the same.
Date: Tue, 15 Jan 2013 16:24:49 -0800
Message-Id: <1358295894-24167-13-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1358295894-24167-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1358295894-24167-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Cody P Schafer <jmesmon@gmail.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

From: Cody P Schafer <jmesmon@gmail.com>

Replace open coded pgdat_end_pfn() with helper function.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/memory_hotplug.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 8e352fe..0a74b86a 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -189,7 +189,7 @@ void register_page_bootmem_info_node(struct pglist_data *pgdat)
 	}
 
 	pfn = pgdat->node_start_pfn;
-	end_pfn = pfn + pgdat->node_spanned_pages;
+	end_pfn = pgdat_end_pfn(pgdat);
 
 	/* register_section info */
 	for (; pfn < end_pfn; pfn += PAGES_PER_SECTION) {
-- 
1.8.0.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
