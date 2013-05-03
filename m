Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 8A2DE6B0294
	for <linux-mm@kvack.org>; Thu,  2 May 2013 20:01:50 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 2 May 2013 20:01:49 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 48A0438C8051
	for <linux-mm@kvack.org>; Thu,  2 May 2013 20:01:47 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4301lpl61014094
	for <linux-mm@kvack.org>; Thu, 2 May 2013 20:01:47 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4301k20027023
	for <linux-mm@kvack.org>; Thu, 2 May 2013 20:01:46 -0400
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 29/31] mm/page_alloc: make pr_err() in page_outside_zone_boundaries() more useful
Date: Thu,  2 May 2013 17:01:01 -0700
Message-Id: <1367539263-19999-30-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Simon Jeons <simon.jeons@gmail.com>

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/page_alloc.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3695ca5..4fe35b24 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -254,8 +254,11 @@ static int page_outside_zone_boundaries(struct zone *zone, struct page *page)
 	} while (zone_span_seqretry(zone, seq));
 
 	if (ret)
-		pr_err("page %lu outside zone [ %lu - %lu ]\n",
-			pfn, start_pfn, start_pfn + sp);
+		pr_err("page with pfn %05lx outside zone %s with pfn range {%05lx-%05lx} in node %d with pfn range {%05lx-%05lx}\n",
+			pfn, zone->name, start_pfn, start_pfn + sp,
+			zone->zone_pgdat->node_id,
+			zone->zone_pgdat->node_start_pfn,
+			pgdat_end_pfn(zone->zone_pgdat));
 
 	return ret;
 }
-- 
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
