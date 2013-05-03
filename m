Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id A44D06B0270
	for <linux-mm@kvack.org>; Thu,  2 May 2013 20:01:17 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 2 May 2013 20:01:16 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 5D3D46E804B
	for <linux-mm@kvack.org>; Thu,  2 May 2013 20:01:12 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4301FSq321000
	for <linux-mm@kvack.org>; Thu, 2 May 2013 20:01:15 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4301Fin011314
	for <linux-mm@kvack.org>; Thu, 2 May 2013 20:01:15 -0400
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [RFC PATCH v3 06/31] mm: add nid_zone() helper
Date: Thu,  2 May 2013 17:00:38 -0700
Message-Id: <1367539263-19999-7-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1367539263-19999-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>, Simon Jeons <simon.jeons@gmail.com>

Add nid_zone(), which returns the zone corresponding to a given nid & zonenum.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 include/linux/mm.h | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1a7f19e..2004713 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -711,9 +711,14 @@ static inline void page_nid_reset_last(struct page *page)
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
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
