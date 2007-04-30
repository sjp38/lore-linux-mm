From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070430185604.7142.39234.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070430185524.7142.56162.sendpatchset@skynet.skynet.ie>
References: <20070430185524.7142.56162.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 2/4] Remove alloc_zeroed_user_highpage()
Date: Mon, 30 Apr 2007 19:56:04 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

alloc_zeroed_user_highpage() has no in-tree users and it is not exported.
Rather than marking it __deprecated, this patch deletes the function.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Andy Whitcroft <apw@shadowen.org>
---

 highmem.h |   15 ---------------
 1 files changed, 15 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc7-mm2-000_m68knommu/include/linux/highmem.h linux-2.6.21-rc7-mm2-001_deprecate/include/linux/highmem.h
--- linux-2.6.21-rc7-mm2-000_m68knommu/include/linux/highmem.h	2007-04-27 22:04:33.000000000 +0100
+++ linux-2.6.21-rc7-mm2-001_deprecate/include/linux/highmem.h	2007-04-30 16:06:24.000000000 +0100
@@ -98,21 +98,6 @@ __alloc_zeroed_user_highpage(gfp_t movab
 #endif
 
 /**
- * alloc_zeroed_user_highpage - Allocate a zeroed HIGHMEM page for a VMA
- * @vma: The VMA the page is to be allocated for
- * @vaddr: The virtual address the page will be inserted into
- *
- * This function will allocate a page for a VMA that the caller knows will
- * not be able to move in the future using move_pages() or reclaim. If it
- * is known that the page can move, use alloc_zeroed_user_highpage_movable
- */
-static inline struct page *
-alloc_zeroed_user_highpage(struct vm_area_struct *vma, unsigned long vaddr)
-{
-	return __alloc_zeroed_user_highpage(0, vma, vaddr);
-}
-
-/**
  * alloc_zeroed_user_highpage_movable - Allocate a zeroed HIGHMEM page for a VMA that the caller knows can move
  * @vma: The VMA the page is to be allocated for
  * @vaddr: The virtual address the page will be inserted into

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
