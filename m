From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 05/23] VM: Allow get_page_unless_zero on compound pages
Date: Tue, 06 Nov 2007 17:11:35 -0800
Message-ID: <20071107011227.588177188@sgi.com>
References: <20071107011130.382244340@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757177AbXKGBOS@vger.kernel.org>
Content-Disposition: inline; filename=0011-slab_defrag_get_page_unless.patch
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundatin.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>
List-Id: linux-mm.kvack.org

SLUB uses compound pages for larger slabs. We need to increment
the page count of these pages in order to make sure that they are not
freed under us because of other operations on the slab that may
independently remove the objects.

[This patch is already in mm]

Reviewed-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Christoph Lameter <clameter@sgi.com>
---
 include/linux/mm.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.23-mm1/include/linux/mm.h
===================================================================
--- linux-2.6.23-mm1.orig/include/linux/mm.h	2007-10-12 18:15:57.000000000 -0700
+++ linux-2.6.23-mm1/include/linux/mm.h	2007-10-12 18:17:30.000000000 -0700
@@ -227,7 +227,7 @@ static inline int put_page_testzero(stru
  */
 static inline int get_page_unless_zero(struct page *page)
 {
-	VM_BUG_ON(PageCompound(page));
+	VM_BUG_ON(PageTail(page));
 	return atomic_inc_not_zero(&page->_count);
 }
 

-- 
