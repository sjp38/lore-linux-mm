From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 2/7] slob: use PG_slab for identifying SLOB pages
Date: Thu, 07 May 2009 09:21:19 +0800
Message-ID: <20090507014914.067348097@intel.com>
References: <20090507012116.996644836@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B81BD6B004F
	for <linux-mm@kvack.org>; Wed,  6 May 2009 21:49:36 -0400 (EDT)
Content-Disposition: inline; filename=mm-slob-page-flag.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Matt Mackall <mpm@selenic.com>, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

For the sake of consistency.

Cc: Matt Mackall <mpm@selenic.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/page-flags.h |    2 --
 mm/slob.c                  |    6 +++---
 2 files changed, 3 insertions(+), 5 deletions(-)

--- linux.orig/include/linux/page-flags.h
+++ linux/include/linux/page-flags.h
@@ -120,7 +120,6 @@ enum pageflags {
 	PG_savepinned = PG_dirty,
 
 	/* SLOB */
-	PG_slob_page = PG_active,
 	PG_slob_free = PG_private,
 
 	/* SLUB */
@@ -203,7 +202,6 @@ PAGEFLAG(SavePinned, savepinned);			/* X
 PAGEFLAG(Reserved, reserved) __CLEARPAGEFLAG(Reserved, reserved)
 PAGEFLAG(SwapBacked, swapbacked) __CLEARPAGEFLAG(SwapBacked, swapbacked)
 
-__PAGEFLAG(SlobPage, slob_page)
 __PAGEFLAG(SlobFree, slob_free)
 
 __PAGEFLAG(SlubFrozen, slub_frozen)
--- linux.orig/mm/slob.c
+++ linux/mm/slob.c
@@ -132,17 +132,17 @@ static LIST_HEAD(free_slob_large);
  */
 static inline int is_slob_page(struct slob_page *sp)
 {
-	return PageSlobPage((struct page *)sp);
+	return PageSlab((struct page *)sp);
 }
 
 static inline void set_slob_page(struct slob_page *sp)
 {
-	__SetPageSlobPage((struct page *)sp);
+	__SetPageSlab((struct page *)sp);
 }
 
 static inline void clear_slob_page(struct slob_page *sp)
 {
-	__ClearPageSlobPage((struct page *)sp);
+	__ClearPageSlab((struct page *)sp);
 }
 
 static inline struct slob_page *slob_page(const void *addr)

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
