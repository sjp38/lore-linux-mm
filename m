Date: Mon, 8 Oct 2007 17:03:20 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH] remap_file_pages: kernel-doc corrections
Message-Id: <20071008170320.eb123276.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Randy Dunlap <randy.dunlap@oracle.com>
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm <akpm@linux-foundation.org>, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

Fix kernel-doc for sys_remap_file_pages() and add info to the __prot NOTE.

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 mm/fremap.c |   20 +++++++++++---------
 1 file changed, 11 insertions(+), 9 deletions(-)

--- linux-2.6.23-rc9-git3.orig/mm/fremap.c
+++ linux-2.6.23-rc9-git3/mm/fremap.c
@@ -97,23 +97,25 @@ static int populate_range(struct mm_stru
 
 }
 
-/***
- * sys_remap_file_pages - remap arbitrary pages of a shared backing store
- *                        file within an existing vma.
+/**
+ * sys_remap_file_pages - remap arbitrary pages of a shared backing store file
  * @start: start of the remapped virtual memory range
  * @size: size of the remapped virtual memory range
- * @prot: new protection bits of the range
- * @pgoff: to be mapped page of the backing store file
+ * @__prot: new protection bits of the range (see NOTE)
+ * @pgoff: to-be-mapped page of the backing store file
  * @flags: 0 or MAP_NONBLOCKED - the later will cause no IO.
  *
- * this syscall works purely via pagetables, so it's the most efficient
+ * sys_remap_file_pages remaps arbitrary pages of a shared backing store file
+ * within an existing vma.
+ *
+ * This syscall works purely via pagetables, so it's the most efficient
  * way to map the same (large) file into a given virtual window. Unlike
  * mmap()/mremap() it does not create any new vmas. The new mappings are
  * also safe across swapout.
  *
- * NOTE: the 'prot' parameter right now is ignored, and the vma's default
- * protection is used. Arbitrary protections might be implemented in the
- * future.
+ * NOTE: the '__prot' parameter right now is ignored (but must be zero),
+ * and the vma's default protection is used. Arbitrary protections
+ * might be implemented in the future.
  */
 asmlinkage long sys_remap_file_pages(unsigned long start, unsigned long size,
 	unsigned long __prot, unsigned long pgoff, unsigned long flags)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
