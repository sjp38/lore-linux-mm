From: Daniel Kiper <dkiper@net-space.pl>
Subject: [PATCH 3/4] mm: pfn_to_section_nr()/section_nr_to_pfn() is valid only in CONFIG_SPARSEMEM context
Date: Mon, 2 May 2011 23:21:00 +0200
Message-ID: <20110502212100.GD4623__12293.1959610016$1304371301$gmane$org@router-fw-old.local.net-space.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1QH0Yc-0007lF-Mn
	for glkm-linux-mm-2@m.gmane.org; Mon, 02 May 2011 23:21:30 +0200
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 17B106B0012
	for <linux-mm@kvack.org>; Mon,  2 May 2011 17:21:29 -0400 (EDT)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1580988Ab1EBVVA (ORCPT <rfc822;linux-mm@kvack.org>);
	Mon, 2 May 2011 23:21:00 +0200
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer

pfn_to_section_nr()/section_nr_to_pfn() is valid only
in CONFIG_SPARSEMEM context. Move it to proper place.

Signed-off-by: Daniel Kiper <dkiper@net-space.pl>
---
 include/linux/mmzone.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index e56f835..d715200 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -928,9 +928,6 @@ static inline unsigned long early_pfn_to_nid(unsigned long pfn)
 #define pfn_to_nid(pfn)		(0)
 #endif
 
-#define pfn_to_section_nr(pfn) ((pfn) >> PFN_SECTION_SHIFT)
-#define section_nr_to_pfn(sec) ((sec) << PFN_SECTION_SHIFT)
-
 #ifdef CONFIG_SPARSEMEM
 
 /*
@@ -956,6 +953,9 @@ static inline unsigned long early_pfn_to_nid(unsigned long pfn)
 #error Allocator MAX_ORDER exceeds SECTION_SIZE
 #endif
 
+#define pfn_to_section_nr(pfn) ((pfn) >> PFN_SECTION_SHIFT)
+#define section_nr_to_pfn(sec) ((sec) << PFN_SECTION_SHIFT)
+
 struct page;
 struct page_cgroup;
 struct mem_section {
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
