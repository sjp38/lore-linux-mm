Message-Id: <200405222210.i4MMApr13955@mail.osdl.org>
Subject: [patch 37/57] rmap.c comment/style fixups
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:10:20 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org, hch@lst.de
List-ID: <linux-mm.kvack.org>

From: Christoph Hellwig <hch@lst.de>


---

 25-akpm/mm/rmap.c |   36 +++++++++++++++---------------------
 1 files changed, 15 insertions(+), 21 deletions(-)

diff -puN mm/rmap.c~rmapc-comment-style-fixups mm/rmap.c
--- 25/mm/rmap.c~rmapc-comment-style-fixups	2004-05-22 14:56:27.402925648 -0700
+++ 25-akpm/mm/rmap.c	2004-05-22 14:59:38.322901400 -0700
@@ -148,15 +148,11 @@ static inline void clear_page_anon(struc
 		free_anonmm(anonmm);
 }
 
-/**
- ** VM stuff below this comment
- **/
-
 /*
  * At what user virtual address is pgoff expected in file-backed vma?
  */
-static inline
-unsigned long vma_address(struct vm_area_struct *vma, pgoff_t pgoff)
+static inline unsigned long
+vma_address(struct vm_area_struct *vma, pgoff_t pgoff)
 {
 	unsigned long address;
 
@@ -165,11 +161,10 @@ unsigned long vma_address(struct vm_area
 	return address;
 }
 
-/**
- ** Subfunctions of page_referenced: page_referenced_one called
- ** repeatedly from either page_referenced_anon or page_referenced_file.
- **/
-
+/*
+ * Subfunctions of page_referenced: page_referenced_one called
+ * repeatedly from either page_referenced_anon or page_referenced_file.
+ */
 static int page_referenced_one(struct page *page,
 	struct mm_struct *mm, unsigned long address,
 	unsigned int *mapcount, int *failed)
@@ -265,9 +260,9 @@ static inline int page_referenced_anon(s
 
 	/*
 	 * The warning below may appear if page_referenced catches the
-	 * page in between page_add_rmap and its replacement demanded
-	 * by mremap_moved_anon_page: so remove the warning once we're
-	 * convinced that anonmm rmap really is finding its pages.
+	 * page in between page_add_{anon,file}_rmap and its replacement
+	 * demanded by mremap_moved_anon_page: so remove the warning once
+	 * we're convinced that anonmm rmap really is finding its pages.
 	 */
 	WARN_ON(!failed);
 out:
@@ -300,7 +295,7 @@ migrate:
  *
  * This function is only called from page_referenced for object-based pages.
  *
- * The semaphore address_space->i_mmap_lock is tried.  If it can't be gotten,
+ * The spinlock address_space->i_mmap_lock is tried.  If it can't be gotten,
  * assume a reference count of 0, so try_to_unmap will then have a go.
  */
 static inline int page_referenced_file(struct page *page)
@@ -478,11 +473,10 @@ int fastcall mremap_move_anon_rmap(struc
 	return move;
 }
 
-/**
- ** Subfunctions of try_to_unmap: try_to_unmap_one called
- ** repeatedly from either try_to_unmap_anon or try_to_unmap_file.
- **/
-
+/*
+ * Subfunctions of try_to_unmap: try_to_unmap_one called
+ * repeatedly from either try_to_unmap_anon or try_to_unmap_file.
+ */
 static int try_to_unmap_one(struct page *page,
 	struct mm_struct *mm, unsigned long address,
 	unsigned int *mapcount, struct vm_area_struct *vma)
@@ -721,7 +715,7 @@ out:
  *
  * This function is only called from try_to_unmap for object-based pages.
  *
- * The semaphore address_space->i_mmap_lock is tried.  If it can't be gotten,
+ * The spinlock address_space->i_mmap_lock is tried.  If it can't be gotten,
  * return a temporary error.
  */
 static inline int try_to_unmap_file(struct page *page)

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
