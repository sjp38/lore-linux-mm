Date: Thu, 13 Mar 2008 10:40:30 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -mmotm] mm: rmap kernel-doc fixes
Message-Id: <20080313104030.f69b7df7.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Randy Dunlap <randy.dunlap@oracle.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Correct kernel-doc function names and parameters in rmap.c.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 mm/rmap.c |   13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

--- linux-2.6.25-rc5.orig/mm/rmap.c
+++ linux-2.6.25-rc5/mm/rmap.c
@@ -335,6 +335,7 @@ static int page_referenced_anon(struct p
 /**
  * page_referenced_file - referenced check for object-based rmap
  * @page: the page we're checking references on.
+ * @mem_cont: target memory controller
  *
  * For an object-based mapped page, find all the places it is mapped and
  * check/clear the referenced flag.  This is done by following the page->mapping
@@ -402,6 +403,7 @@ static int page_referenced_file(struct p
  * page_referenced - test if the page was referenced
  * @page: the page to test
  * @is_locked: caller holds lock on the page
+ * @mem_cont: target memory controller
  *
  * Quick test_and_clear_referenced for all mappings to a page,
  * returns the number of ptes which referenced the page.
@@ -506,7 +508,7 @@ int page_mkclean(struct page *page)
 EXPORT_SYMBOL_GPL(page_mkclean);
 
 /**
- * page_set_anon_rmap - setup new anonymous rmap
+ * __page_set_anon_rmap - setup new anonymous rmap
  * @page:	the page to add the mapping to
  * @vma:	the vm area in which the mapping is added
  * @address:	the user virtual address mapped
@@ -530,7 +532,7 @@ static void __page_set_anon_rmap(struct 
 }
 
 /**
- * page_set_anon_rmap - sanity check anonymous rmap addition
+ * __page_check_anon_rmap - sanity check anonymous rmap addition
  * @page:	the page to add the mapping to
  * @vma:	the vm area in which the mapping is added
  * @address:	the user virtual address mapped
@@ -583,7 +585,7 @@ void page_add_anon_rmap(struct page *pag
 	}
 }
 
-/*
+/**
  * page_add_new_anon_rmap - add pte mapping to a new anonymous page
  * @page:	the page to add the mapping to
  * @vma:	the vm area in which the mapping is added
@@ -623,6 +625,8 @@ void page_add_file_rmap(struct page *pag
 /**
  * page_dup_rmap - duplicate pte mapping to a page
  * @page:	the page to add the mapping to
+ * @vma:	the vm area being duplicated
+ * @address:	the user virtual address mapped
  *
  * For copy_page_range only: minimal extract from page_add_file_rmap /
  * page_add_anon_rmap, avoiding unnecessary tests (already checked) so it's
@@ -642,6 +646,7 @@ void page_dup_rmap(struct page *page, st
 /**
  * page_remove_rmap - take down pte mapping from a page
  * @page: page to remove mapping from
+ * @vma: the vm area in which the mapping is removed
  *
  * The caller needs to hold the pte lock.
  */
@@ -889,6 +894,7 @@ static int try_to_unmap_anon(struct page
 /**
  * try_to_unmap_file - unmap file page using the object-based rmap method
  * @page: the page to unmap
+ * @migration: migration flag
  *
  * Find all the mappings of a page using the mapping pointer and the vma chains
  * contained in the address_space struct it points to.
@@ -985,6 +991,7 @@ out:
 /**
  * try_to_unmap - try to remove all page table mappings to a page
  * @page: the page to get unmapped
+ * @migration: migration flag
  *
  * Tries to remove all the page table entries which are mapping this
  * page, used in the pageout path.  Caller must hold the page lock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
