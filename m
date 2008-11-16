From: Helge Deller <deller@gmx.de>
Subject: [PATCH, 2.6.28-rc5] unitialized return value in mm/mlock.c: __mlock_vma_pages_range()
Date: Mon, 17 Nov 2008 00:30:57 +0100
MIME-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200811170030.58246.deller@gmx.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, Kyle Mc Martin <kyle@hera.kernel.org>, linux-parisc@vger.kernel.org, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Fix an unitialized return value when compiling on parisc (with CONFIG_UNEVICTABLE_LRU=y):
	mm/mlock.c: In function `__mlock_vma_pages_range':
	mm/mlock.c:165: warning: `ret' might be used uninitialized in this function

Signed-off-by: Helge Deller <deller@gmx.de>

--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -162,7 +162,7 @@ static long __mlock_vma_pages_range(struct vm_area_struct *vma,
 	unsigned long addr = start;
 	struct page *pages[16]; /* 16 gives a reasonable batch */
 	int nr_pages = (end - start) / PAGE_SIZE;
-	int ret;
+	int ret = 0;
 	int gup_flags = 0;
 
 	VM_BUG_ON(start & ~PAGE_MASK);



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
