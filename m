Message-Id: <200404110203.i3B23pF17863@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: typo in mm/hugetlb.c
Date: Sat, 10 Apr 2004 19:03:52 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

People might caught this already: mm/hugetlb.c doesn't compile for
x86 in linux-2.6.5-mm3 due to a typo and a missing semicolon.

Patch to fix compile error when highmem is turned on.

diff -Nrup linux-2.6.5/mm/hugetlb.c linux-2.6.5.ken/mm/hugetlb.c
--- linux-2.6.5/mm/hugetlb.c	2004-04-10 18:44:37.000000000 -0700
+++ linux-2.6.5.ken/mm/hugetlb.c	2004-04-10 18:45:31.000000000 -0700
@@ -140,11 +140,11 @@ static int try_to_free_low(unsigned long
 	for (i = 0; i < MAX_NUMNODES; ++i) {
 		struct page *page;
 		list_for_each_entry(page, &hugepage_freelists[i], lru) {
-			if (PageHighmem(page))
+			if (PageHighMem(page))
 				continue;
 			list_del(&page->lru);
 			update_and_free_page(page);
-			--free_huge_pages
+			--free_huge_pages;
 			if (!--count)
 				return 0;
 		}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
