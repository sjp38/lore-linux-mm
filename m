From: Andi Kleen <andi@firstfloor.org>
References: <20080317258.659191058@firstfloor.org>
In-Reply-To: <20080317258.659191058@firstfloor.org>
Subject: [PATCH] [9/18] Export prep_compound_page to the hugetlb allocator
Message-Id: <20080317015823.025301B41E0@basil.firstfloor.org>
Date: Mon, 17 Mar 2008 02:58:23 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, pj@sgi.com, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

hugetlb will need to get compound pages from bootmem to handle
the case of them being larger than MAX_ORDER. Export
the constructor function needed for this.

Signed-off-by: Andi Kleen <ak@suse.de>

---
 mm/internal.h   |    2 ++
 mm/page_alloc.c |    2 +-
 2 files changed, 3 insertions(+), 1 deletion(-)

Index: linux/mm/internal.h
===================================================================
--- linux.orig/mm/internal.h
+++ linux/mm/internal.h
@@ -13,6 +13,8 @@
 
 #include <linux/mm.h>
 
+extern void prep_compound_page(struct page *page, unsigned long order);
+
 static inline void set_page_count(struct page *page, int v)
 {
 	atomic_set(&page->_count, v);
Index: linux/mm/page_alloc.c
===================================================================
--- linux.orig/mm/page_alloc.c
+++ linux/mm/page_alloc.c
@@ -272,7 +272,7 @@ static void free_compound_page(struct pa
 	__free_pages_ok(page, compound_order(page));
 }
 
-static void prep_compound_page(struct page *page, unsigned long order)
+void prep_compound_page(struct page *page, unsigned long order)
 {
 	int i;
 	int nr_pages = 1 << order;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
