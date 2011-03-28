Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0364F8D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 05:23:57 -0400 (EDT)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1578893Ab1C1JXK (ORCPT <rfc822;linux-mm@kvack.org>);
	Mon, 28 Mar 2011 11:23:10 +0200
Date: Mon, 28 Mar 2011 11:23:10 +0200
From: Daniel Kiper <dkiper@net-space.pl>
Subject: [PATCH 1/3] mm: Optimize pfn calculation in online_page()
Message-ID: <20110328092310.GB13826@router-fw-old.local.net-space.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

If CONFIG_FLATMEM is enabled pfn is calculated in online_page()
more than once. It is possible to optimize that and use value
established at beginning of that function.

Signed-off-by: Daniel Kiper <dkiper@net-space.pl>
---
 mm/memory_hotplug.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 321fc74..f0651ae 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -375,7 +375,7 @@ void online_page(struct page *page)
 #endif
 
 #ifdef CONFIG_FLATMEM
-	max_mapnr = max(page_to_pfn(page), max_mapnr);
+	max_mapnr = max(pfn, max_mapnr);
 #endif
 
 	ClearPageReserved(page);
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
