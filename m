Message-Id: <200405222209.i4MM9or13730@mail.osdl.org>
Subject: [patch 34/57] unmap_mapping_range: add comment
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:09:17 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>



---

 25-akpm/mm/memory.c |    6 ++++++
 1 files changed, 6 insertions(+)

diff -puN mm/memory.c~unmap_mapping_range-comment mm/memory.c
--- 25/mm/memory.c~unmap_mapping_range-comment	2004-05-22 14:56:27.000986752 -0700
+++ 25-akpm/mm/memory.c	2004-05-22 14:59:38.319901856 -0700
@@ -1183,6 +1183,12 @@ void unmap_mapping_range(struct address_
 	if (unlikely(!prio_tree_empty(&mapping->i_mmap_shared)))
 		unmap_mapping_range_list(&mapping->i_mmap_shared, &details);
 
+	/*
+	 * In nonlinear VMAs there is no correspondence between virtual address
+	 * offset and file offset.  So we must perform an exhaustive search
+	 * across *all* the pages in each nonlinear VMA, not just the pages
+	 * whose virtual address lies outside the file truncation point.
+	 */
 	if (unlikely(!list_empty(&mapping->i_mmap_nonlinear))) {
 		struct vm_area_struct *vma;
 		list_for_each_entry(vma, &mapping->i_mmap_nonlinear,

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
