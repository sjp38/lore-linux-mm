Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 42F7A6B003A
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:14:26 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 11 Apr 2013 21:14:25 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 4758638C804D
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:14:21 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r3C1EL1026607764
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 21:14:21 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r3C1EKGJ015679
	for <linux-mm@kvack.org>; Thu, 11 Apr 2013 22:14:21 -0300
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [RFC PATCH v2 06/25] mm: add nid_zone() helper
Date: Thu, 11 Apr 2013 18:13:38 -0700
Message-Id: <1365729237-29711-7-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1365729237-29711-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1365729237-29711-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Simon Jeons <simon.jeons@gmail.com>

Add nid_zone(), which returns the zone corresponding to a given nid & zonenum.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 include/linux/mm.h | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 9ddae00..1b6abae 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -708,9 +708,14 @@ static inline void page_nid_reset_last(struct page *page)
 }
 #endif
 
+static inline struct zone *nid_zone(int nid, enum zone_type zonenum)
+{
+	return &NODE_DATA(nid)->node_zones[zonenum];
+}
+
 static inline struct zone *page_zone(const struct page *page)
 {
-	return &NODE_DATA(page_to_nid(page))->node_zones[page_zonenum(page)];
+	return nid_zone(page_to_nid(page), page_zonenum(page));
 }
 
 #ifdef SECTION_IN_PAGE_FLAGS
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
