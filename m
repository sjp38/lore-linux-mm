Message-Id: <20080603100939.220982006@amd.local0.net>
References: <20080603095956.781009952@amd.local0.net>
Date: Tue, 03 Jun 2008 20:00:04 +1000
From: npiggin@suse.de
Subject: [patch 08/21] mm: export prep_compound_page to mm
Content-Disposition: inline; filename=mm-export-prep_compound_page.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm@kvack.org, Adam Litke <agl@us.ibm.com>, kniht@us.ibm.com, andi@firstfloor.org, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

hugetlb will need to get compound pages from bootmem to handle the case of them
being greater than or equal to MAX_ORDER. Export the constructor function
needed for this.

Acked-by: Adam Litke <agl@us.ibm.com>
Signed-off-by: Andi Kleen <ak@suse.de>
Signed-off-by: Nick Piggin <npiggin@suse.de>
---
 mm/internal.h   |    2 ++
 mm/page_alloc.c |    2 +-
 2 files changed, 3 insertions(+), 1 deletion(-)

Index: linux-2.6/mm/internal.h
===================================================================
--- linux-2.6.orig/mm/internal.h	2008-06-03 19:52:49.000000000 +1000
+++ linux-2.6/mm/internal.h	2008-06-03 19:56:48.000000000 +1000
@@ -16,6 +16,8 @@
 void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
 
+extern void prep_compound_page(struct page *page, unsigned long order);
+
 static inline void set_page_count(struct page *page, int v)
 {
 	atomic_set(&page->_count, v);
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c	2008-06-03 19:52:49.000000000 +1000
+++ linux-2.6/mm/page_alloc.c	2008-06-03 19:56:48.000000000 +1000
@@ -288,7 +288,7 @@ static void free_compound_page(struct pa
 	__free_pages_ok(page, compound_order(page));
 }
 
-static void prep_compound_page(struct page *page, unsigned long order)
+void prep_compound_page(struct page *page, unsigned long order)
 {
 	int i;
 	int nr_pages = 1 << order;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
