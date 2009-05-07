From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 6/7] pagemap: document 9 more exported page flags
Date: Thu, 07 May 2009 09:21:23 +0800
Message-ID: <20090507014914.636803082@intel.com>
References: <20090507012116.996644836@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id CD31E6B003D
	for <linux-mm@kvack.org>; Wed,  6 May 2009 21:49:28 -0400 (EDT)
Content-Disposition: inline; filename=kpageflags-doc.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Wu Fengguang <fengguang.wu@intel.com>, Matt Mackall <mpm@selenic.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

Also add short descriptions for all of the 20 exported page flags.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 Documentation/vm/pagemap.txt |   66 +++++++++++++++++++++++++++++++++
 1 file changed, 66 insertions(+)

--- linux.orig/Documentation/vm/pagemap.txt
+++ linux/Documentation/vm/pagemap.txt
@@ -49,6 +49,72 @@ There are three components to pagemap:
      8. WRITEBACK
      9. RECLAIM
     10. BUDDY
+    11. MMAP
+    12. ANON
+    13. SWAPCACHE
+    14. SWAPBACKED
+    15. COMPOUND_HEAD
+    16. COMPOUND_TAIL
+    16. HUGE
+    18. UNEVICTABLE
+    19. HWPOISON
+    20. NOPAGE
+
+Short descriptions to the page flags:
+
+ 0. LOCKED
+    page is being locked for exclusive access, eg. by undergoing read/write IO
+
+ 7. SLAB
+    page is managed by the SLAB/SLOB/SLUB/SLQB kernel memory allocator
+    When compound page is used, SLUB/SLQB will only set this flag on the head
+    page; SLOB will not flag it at all.
+
+10. BUDDY
+    a free memory block managed by the buddy system allocator
+    The buddy system organizes free memory in blocks of various orders.
+    An order N block has 2^N physically contiguous pages, with the BUDDY flag
+    set for and _only_ for the first page.
+
+15. COMPOUND_HEAD
+16. COMPOUND_TAIL
+    A compound page with order N consists of 2^N physically contiguous pages.
+    A compound page with order 2 takes the form of "HTTT", where H donates its
+    head page and T donates its tail page(s).  The major consumers of compound
+    pages are hugeTLB pages (Documentation/vm/hugetlbpage.txt), the SLUB etc.
+    memory allocators and various device drivers. However in this interface,
+    only huge/giga pages are made visible to end users.
+17. HUGE
+    this is an integral part of a HugeTLB page
+
+19. HWPOISON
+    hardware detected memory corruption on this page: don't touch the data!
+
+20. NOPAGE
+    no page frame exists at the requested address
+
+    [IO related page flags]
+ 1. ERROR     IO error occurred
+ 3. UPTODATE  page has up-to-date data
+              ie. for file backed page: (in-memory data revision >= on-disk one)
+ 4. DIRTY     page has been written to, hence contains new data
+              ie. for file backed page: (in-memory data revision >  on-disk one)
+ 8. WRITEBACK page is being synced to disk
+
+    [LRU related page flags]
+ 5. LRU         page is in one of the LRU lists
+ 6. ACTIVE      page is in the active LRU list
+18. UNEVICTABLE page is in the unevictable (non-)LRU list
+                It is somehow pinned and not a candidate for LRU page reclaims,
+		eg. ramfs pages, shmctl(SHM_LOCK) and mlock() memory segments
+ 2. REFERENCED  page has been referenced since last LRU list enqueue/requeue
+ 9. RECLAIM     page will be reclaimed soon after its pageout IO completed
+11. MMAP        a memory mapped page
+12. ANON        a memory mapped page that is not part of a file
+13. SWAPCACHE   page is mapped to swap space, ie. has an associated swap entry
+14. SWAPBACKED  page is backed by swap/RAM
+
+The page-types tool in this directory can be used to query the above flags.
 
 Using pagemap to do something useful:
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
