From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Tue, 19 Aug 2008 17:05:15 -0400
Message-Id: <20080819210515.27199.60378.sendpatchset@lts-notebook>
In-Reply-To: <20080819210509.27199.6626.sendpatchset@lts-notebook>
References: <20080819210509.27199.6626.sendpatchset@lts-notebook>
Subject: [PATCH 1/6] Mlock:  fix __mlock_vma_pages_range comment block
Sender: owner-linux-mm@kvack.org
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: riel@redhat.com, linux-mm <linux-mm@kvack.org>, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Against:  2.6.27-rc3-mmotm-080819-0259:

fix to mmap-handle-mlocked-pages-during-map-remap-unmap.patch

__mlock_vma_pages_range comment block needs updating:
 - it fails to mention the mlock parameter
 - no longer requires that mmap_sem be held for write.

following patch fixes it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/mlock.c |   16 ++++++++++++----
 1 file changed, 12 insertions(+), 4 deletions(-)

Index: linux-2.6.27-rc3-mmotm/mm/mlock.c
===================================================================
--- linux-2.6.27-rc3-mmotm.orig/mm/mlock.c	2008-08-18 11:41:19.000000000 -0400
+++ linux-2.6.27-rc3-mmotm/mm/mlock.c	2008-08-18 11:48:13.000000000 -0400
@@ -112,12 +112,20 @@ static void munlock_vma_page(struct page
 	}
 }
 
-/*
- * mlock a range of pages in the vma.
+/**
+ * __mlock_vma_pages_range() -  mlock/munlock a range of pages in the vma.
+ * @vma:   target vma
+ * @start: start address
+ * @end:   end address
+ * @mlock: 0 indicate munlock, otherwise mlock.
+ *
+ * If @mlock == 0, unlock an mlocked range;
+ * else mlock the range of pages.  This takes care of making the pages present ,
+ * too.
  *
- * This takes care of making the pages present too.
+ * return 0 on success, negative error code on error.
  *
- * vma->vm_mm->mmap_sem must be held for write.
+ * vma->vm_mm->mmap_sem must be held for at least read.
  */
 static int __mlock_vma_pages_range(struct vm_area_struct *vma,
 				   unsigned long start, unsigned long end,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
