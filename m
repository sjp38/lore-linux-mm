Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 7C9DA6B005A
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 00:39:38 -0400 (EDT)
Received: from /spool/local
	by e2.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@shangw.pok.ibm.com>;
	Tue, 17 Jul 2012 00:39:37 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 28C5F6E804C
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 00:39:32 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6H4dVW14784452
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 00:39:31 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6HAAOmm008915
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 06:10:24 -0400
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH] mm/vmscan: remove checking on PG_lru
Date: Tue, 17 Jul 2012 12:44:14 +0800
Message-Id: <1342500254-28384-1-git-send-email-shangw@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: rientjes@google.com, akpm@linux-foundation.org, Gavin Shan <shangw@linux.vnet.ibm.com>

Function __isolate_lru_page() is called by isolate_lru_pages() or
isolate_migratepages_range(). For both cases, the PG_lru flag for
the target page frame has been checked. So we needn't check that
again in function __isolate_lru_page() and just remove the check
in function __isolate_lru_page().

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
---
 mm/vmscan.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 6615763..77d5704 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -940,10 +940,6 @@ int __isolate_lru_page(struct page *page, isolate_mode_t mode)
 {
 	int ret = -EINVAL;
 
-	/* Only take pages on the LRU. */
-	if (!PageLRU(page))
-		return ret;
-
 	/* Do not give back unevictable pages for compaction */
 	if (PageUnevictable(page))
 		return ret;
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
