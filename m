Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 340AB6B0011
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 15:45:14 -0500 (EST)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Thu, 28 Feb 2013 13:45:12 -0700
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 7FC9519D8046
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 13:45:07 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1SKj2nJ026940
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 13:45:03 -0700
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1SKlXJi026516
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 13:47:33 -0700
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 09/24] mm: add nid_zone() helper
Date: Thu, 28 Feb 2013 12:44:17 -0800
Message-Id: <1362084272-11282-10-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
References: <20130228024112.GA24970@negative>
 <1362084272-11282-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: David Hansen <dave@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

Add nid_zone(), which returns the zone corresponding to a given nid & zonenum.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 include/linux/mm.h | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index e7c3f9a..562304a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -707,9 +707,14 @@ static inline void page_nid_reset_last(struct page *page)
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
1.8.1.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
