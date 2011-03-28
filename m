Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 459788D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 05:25:09 -0400 (EDT)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1578635Ab1C1JYM (ORCPT <rfc822;linux-mm@kvack.org>);
	Mon, 28 Mar 2011 11:24:12 +0200
Date: Mon, 28 Mar 2011 11:24:12 +0200
From: Daniel Kiper <dkiper@net-space.pl>
Subject: [PATCH 2/3] mm: Add SECTION_ALIGN_UP() and SECTION_ALIGN_DOWN() macro
Message-ID: <20110328092412.GC13826@router-fw-old.local.net-space.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Add SECTION_ALIGN_UP() and SECTION_ALIGN_DOWN() macro which aligns
given pfn to upper section and lower section boundary accordingly.

Signed-off-by: Daniel Kiper <dkiper@net-space.pl>
---
 include/linux/mmzone.h |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 02ecb01..d342820 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -931,6 +931,9 @@ static inline unsigned long early_pfn_to_nid(unsigned long pfn)
 #define pfn_to_section_nr(pfn) ((pfn) >> PFN_SECTION_SHIFT)
 #define section_nr_to_pfn(sec) ((sec) << PFN_SECTION_SHIFT)
 
+#define SECTION_ALIGN_UP(pfn)	(((pfn) + PAGES_PER_SECTION - 1) & PAGE_SECTION_MASK)
+#define SECTION_ALIGN_DOWN(pfn)	((pfn) & PAGE_SECTION_MASK)
+
 #ifdef CONFIG_SPARSEMEM
 
 /*
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
