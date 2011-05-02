Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id BC6816B0012
	for <linux-mm@kvack.org>; Mon,  2 May 2011 17:22:43 -0400 (EDT)
Received: (from localhost user: 'dkiper' uid#4000 fake: STDIN
	(dkiper@router-fw.net-space.pl)) by router-fw-old.local.net-space.pl
	id S1532337Ab1EBVW0 (ORCPT <rfc822;linux-mm@kvack.org>);
	Mon, 2 May 2011 23:22:26 +0200
Date: Mon, 2 May 2011 23:22:26 +0200
From: Daniel Kiper <dkiper@net-space.pl>
Subject: [PATCH 4/4] mm: Do not define PFN_SECTION_SHIFT if !CONFIG_SPARSEMEM
Message-ID: <20110502212226.GE4623@router-fw-old.local.net-space.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Do not define PFN_SECTION_SHIFT if !CONFIG_SPARSEMEM.

Signed-off-by: Daniel Kiper <dkiper@net-space.pl>
---
 include/linux/mm.h |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 23465e1..d1f8cb4 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -603,10 +603,6 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
 #define NODE_NOT_IN_PAGE_FLAGS
 #endif
 
-#ifndef PFN_SECTION_SHIFT
-#define PFN_SECTION_SHIFT 0
-#endif
-
 /*
  * Define the bit shifts to access each section.  For non-existent
  * sections we define the shift as 0; that plus a 0 mask ensures
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
