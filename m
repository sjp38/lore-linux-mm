Message-Id: <200405222210.i4MMAdr13921@mail.osdl.org>
Subject: [patch 36/57] vm_area_struct size comment
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:10:09 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

From: Hugh Dickins <hugh@veritas.com>

Missed comment on the size of vm_area_struct: it is no longer 64 bytes on
ia32.


---

 25-akpm/include/linux/mm.h |    7 -------
 1 files changed, 7 deletions(-)

diff -puN include/linux/mm.h~vm_area_struct-size-comment include/linux/mm.h
--- 25/include/linux/mm.h~vm_area_struct-size-comment	2004-05-22 14:56:27.278944496 -0700
+++ 25-akpm/include/linux/mm.h	2004-05-22 14:59:38.317902160 -0700
@@ -47,13 +47,6 @@ extern int page_cluster;
  * per VM-area/task.  A VM area is any part of the process virtual memory
  * space that has a special rule for the page-fault handlers (ie a shared
  * library, the executable area etc).
- *
- * This structure is exactly 64 bytes on ia32.  Please think very, very hard
- * before adding anything to it.
- * [Now 4 bytes more on 32bit NUMA machines. Sorry. -AK.
- * But if you want to recover the 4 bytes justr remove vm_next. It is redundant
- * with vm_rb. Will be a lot of editing work though. vm_rb.color is redundant
- * too.]
  */
 struct vm_area_struct {
 	struct mm_struct * vm_mm;	/* The address space we belong to. */

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
