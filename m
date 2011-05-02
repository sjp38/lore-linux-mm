From: Daniel Kiper <dkiper@net-space.pl>
Subject: [PATCH 1/4] mm: Remove dependency on CONFIG_FLATMEM from online_page()
Date: Mon, 2 May 2011 23:19:15 +0200
Message-ID: <20110502211915.GB4623__48211.4864550114$1304371200$gmane$org@router-fw-old.local.net-space.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1QH0X3-0006e2-3p
	for glkm-linux-mm-2@m.gmane.org; Mon, 02 May 2011 23:19:53 +0200
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 74DD46B0023
	for <linux-mm@kvack.org>; Mon,  2 May 2011 17:19:51 -0400 (EDT)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1580691Ab1EBVTP (ORCPT <rfc822;linux-mm@kvack.org>);
	Mon, 2 May 2011 23:19:15 +0200
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer

Memory hotplug code strictly depends on CONFIG_SPARSEMEM.
It means that code depending on CONFIG_FLATMEM in online_page()
is never compiled. Remove it because it is not needed anymore.

Signed-off-by: Daniel Kiper <dkiper@net-space.pl>
---
 mm/memory_hotplug.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 9ca1d60..a807ccb 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -374,10 +374,6 @@ void online_page(struct page *page)
 		totalhigh_pages++;
 #endif
 
-#ifdef CONFIG_FLATMEM
-	max_mapnr = max(pfn, max_mapnr);
-#endif
-
 	ClearPageReserved(page);
 	init_page_count(page);
 	__free_page(page);
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
