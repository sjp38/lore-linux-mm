Date: Mon, 11 Aug 2008 16:05:37 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC PATCH for -mm 2/5] related function comment fixes (optional)
In-Reply-To: <20080811151313.9456.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080811151313.9456.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080811160430.945C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Now, __mlock_vma_pages_range has sevaral wrong comment.
 - don't write about mlock parameter
 - write about require write lock, but it is not true.

following patch fixes it.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 mm/mlock.c |   13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

Index: b/mm/mlock.c
===================================================================
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -144,11 +144,18 @@ static void munlock_vma_page(struct page
 }
 
 /*
- * mlock a range of pages in the vma.
+ * mlock/munlock a range of pages in the vma.
  *
- * This takes care of making the pages present too.
+ * If @mlock==1, this takes care of making the pages present too.
  *
- * vma->vm_mm->mmap_sem must be held for write.
+ * @vma:   target vma
+ * @start: start address
+ * @end:   end address
+ * @mlock: 0 indicate munlock, otherwise mlock.
+ *
+ * return 0 if successed, otherwse return negative value.
+ *
+ * vma->vm_mm->mmap_sem must be held for read.
  */
 static int __mlock_vma_pages_range(struct vm_area_struct *vma,
 				   unsigned long start, unsigned long end,


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
