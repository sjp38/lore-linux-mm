From: Nick Piggin <npiggin@suse.de>
Message-Id: <20061013143556.15438.35419.sendpatchset@linux.site>
In-Reply-To: <20061013143516.15438.8802.sendpatchset@linux.site>
References: <20061013143516.15438.8802.sendpatchset@linux.site>
Subject: [patch 4/6] mm: comment mmap_sem / lock_page lockorder
Date: Fri, 13 Oct 2006 18:44:32 +0200 (CEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>
Cc: Neil Brown <neilb@suse.de>, Andrew Morton <akpm@osdl.org>, Anton Altaparmakov <aia21@cam.ac.uk>, Chris Mason <chris.mason@oracle.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Add a few more examples to the mmap_sem / lock_page ordering.

Signed-off-by: Nick Piggin <npiggin@suse.de>

Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c
+++ linux-2.6/mm/filemap.c
@@ -73,7 +73,7 @@ generic_file_direct_IO(int rw, struct ki
  *        ->mapping->tree_lock	(arch-dependent flush_dcache_mmap_lock)
  *
  *  ->mmap_sem
- *    ->lock_page		(access_process_vm)
+ *    ->lock_page		(page fault, sys_mmap, access_process_vm)
  *
  *  ->mmap_sem
  *    ->i_mutex			(msync)
Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c
+++ linux-2.6/mm/rmap.c
@@ -29,7 +29,7 @@
  * taken together; in truncation, i_mutex is taken outermost.
  *
  * mm->mmap_sem
- *   page->flags PG_locked (lock_page)
+ *   page->flags PG_locked (lock_page, eg from pagefault)
  *     mapping->i_mmap_lock
  *       anon_vma->lock
  *         mm->page_table_lock or pte_lock

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
