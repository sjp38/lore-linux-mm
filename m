From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070430185544.7142.82264.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070430185524.7142.56162.sendpatchset@skynet.skynet.ie>
References: <20070430185524.7142.56162.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 1/4] Fix alloc_zeroed_user_highpage on m68knommu
Date: Mon, 30 Apr 2007 19:55:44 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The patch
add-__gfp_movable-for-callers-to-flag-allocations-from-high-memory-that-may-be-migrated.patch
missed updating m68knommu where alloc_zeroed_user_highpage() changed to
alloc_zeroed_user_highpage_movable(). This patch fixes the problem.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Andy Whitcroft <apw@shadowen.org>
---

 page.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletion(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-rc7-mm2-clean/include/asm-m68knommu/page.h linux-2.6.21-rc7-mm2-000_m68knommu/include/asm-m68knommu/page.h
--- linux-2.6.21-rc7-mm2-clean/include/asm-m68knommu/page.h	2007-04-16 00:50:57.000000000 +0100
+++ linux-2.6.21-rc7-mm2-000_m68knommu/include/asm-m68knommu/page.h	2007-04-30 16:04:31.000000000 +0100
@@ -22,7 +22,8 @@
 #define clear_user_page(page, vaddr, pg)	clear_page(page)
 #define copy_user_page(to, from, vaddr, pg)	copy_page(to, from)
 
-#define alloc_zeroed_user_highpage(vma, vaddr) alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO, vma, vaddr)
+#define __alloc_zeroed_user_highpage(movableflags, vma, vaddr) \
+	alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO | movableflags, vma, vaddr)
 #define __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
