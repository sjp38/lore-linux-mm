Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 313426B0011
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 04:08:20 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id d5-v6so615786qtg.7
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 01:08:20 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 15si940883qkl.47.2018.04.18.01.08.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Apr 2018 01:08:18 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3I883Q1098208
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 04:08:17 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2hdy1ygeew-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 04:08:17 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 18 Apr 2018 09:08:14 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 6/7] docs/admin-guide/mm: start moving here files from Documentation/vm
Date: Wed, 18 Apr 2018 11:07:49 +0300
In-Reply-To: <1524038870-413-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1524038870-413-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1524038870-413-7-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Matthew Wilcox <willy@infradead.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Several documents in Documentation/vm fit quite well into the "admin/user
guide" category. The documents that don't overload the reader with lots of
implementation details and provide coherent description of certain feature
can be moved to Documentation/admin-guide/mm.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/ABI/stable/sysfs-devices-node                 |  2 +-
 Documentation/ABI/testing/sysfs-kernel-mm-hugepages         |  2 +-
 Documentation/{vm => admin-guide/mm}/hugetlbpage.rst        |  0
 Documentation/{vm => admin-guide/mm}/idle_page_tracking.rst |  2 +-
 Documentation/admin-guide/mm/index.rst                      |  9 +++++++++
 Documentation/{vm => admin-guide/mm}/pagemap.rst            |  6 +++---
 Documentation/{vm => admin-guide/mm}/soft-dirty.rst         |  0
 Documentation/{vm => admin-guide/mm}/userfaultfd.rst        |  0
 Documentation/filesystems/proc.txt                          |  6 ++++--
 Documentation/sysctl/vm.txt                                 |  4 ++--
 Documentation/vm/00-INDEX                                   | 10 ----------
 Documentation/vm/hwpoison.rst                               |  2 +-
 Documentation/vm/index.rst                                  |  5 -----
 fs/Kconfig                                                  |  2 +-
 fs/proc/task_mmu.c                                          |  4 ++--
 mm/Kconfig                                                  |  5 +++--
 16 files changed, 28 insertions(+), 31 deletions(-)
 rename Documentation/{vm => admin-guide/mm}/hugetlbpage.rst (100%)
 rename Documentation/{vm => admin-guide/mm}/idle_page_tracking.rst (98%)
 rename Documentation/{vm => admin-guide/mm}/pagemap.rst (96%)
 rename Documentation/{vm => admin-guide/mm}/soft-dirty.rst (100%)
 rename Documentation/{vm => admin-guide/mm}/userfaultfd.rst (100%)

diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
index b38f4b7..3e90e1f 100644
--- a/Documentation/ABI/stable/sysfs-devices-node
+++ b/Documentation/ABI/stable/sysfs-devices-node
@@ -90,4 +90,4 @@ Date:		December 2009
 Contact:	Lee Schermerhorn <lee.schermerhorn@hp.com>
 Description:
 		The node's huge page size control/query attributes.
-		See Documentation/vm/hugetlbpage.rst
\ No newline at end of file
+		See Documentation/admin-guide/mm/hugetlbpage.rst
\ No newline at end of file
diff --git a/Documentation/ABI/testing/sysfs-kernel-mm-hugepages b/Documentation/ABI/testing/sysfs-kernel-mm-hugepages
index 5140b23..fdaa216 100644
--- a/Documentation/ABI/testing/sysfs-kernel-mm-hugepages
+++ b/Documentation/ABI/testing/sysfs-kernel-mm-hugepages
@@ -12,4 +12,4 @@ Description:
 			free_hugepages
 			surplus_hugepages
 			resv_hugepages
-		See Documentation/vm/hugetlbpage.rst for details.
+		See Documentation/admin-guide/mm/hugetlbpage.rst for details.
diff --git a/Documentation/vm/hugetlbpage.rst b/Documentation/admin-guide/mm/hugetlbpage.rst
similarity index 100%
rename from Documentation/vm/hugetlbpage.rst
rename to Documentation/admin-guide/mm/hugetlbpage.rst
diff --git a/Documentation/vm/idle_page_tracking.rst b/Documentation/admin-guide/mm/idle_page_tracking.rst
similarity index 98%
rename from Documentation/vm/idle_page_tracking.rst
rename to Documentation/admin-guide/mm/idle_page_tracking.rst
index d1c4609..92e3a25 100644
--- a/Documentation/vm/idle_page_tracking.rst
+++ b/Documentation/admin-guide/mm/idle_page_tracking.rst
@@ -65,7 +65,7 @@ workload one should:
     are not reclaimable, he or she can filter them out using
     ``/proc/kpageflags``.
 
-See Documentation/vm/pagemap.rst for more information about
+See Documentation/admin-guide/mm/pagemap.rst for more information about
 ``/proc/pid/pagemap``, ``/proc/kpageflags``, and ``/proc/kpagecgroup``.
 
 .. _impl_details:
diff --git a/Documentation/admin-guide/mm/index.rst b/Documentation/admin-guide/mm/index.rst
index c47c16e..6c8b554 100644
--- a/Documentation/admin-guide/mm/index.rst
+++ b/Documentation/admin-guide/mm/index.rst
@@ -17,3 +17,12 @@ are described in Documentation/sysctl/vm.txt and in `man 5 proc`_.
 
 Here we document in detail how to interact with various mechanisms in
 the Linux memory management.
+
+.. toctree::
+   :maxdepth: 1
+
+   hugetlbpage
+   idle_page_tracking
+   pagemap
+   soft-dirty
+   userfaultfd
diff --git a/Documentation/vm/pagemap.rst b/Documentation/admin-guide/mm/pagemap.rst
similarity index 96%
rename from Documentation/vm/pagemap.rst
rename to Documentation/admin-guide/mm/pagemap.rst
index 7ba8cbd..053ca64 100644
--- a/Documentation/vm/pagemap.rst
+++ b/Documentation/admin-guide/mm/pagemap.rst
@@ -18,7 +18,7 @@ There are four components to pagemap:
     * Bits 0-54  page frame number (PFN) if present
     * Bits 0-4   swap type if swapped
     * Bits 5-54  swap offset if swapped
-    * Bit  55    pte is soft-dirty (see Documentation/vm/soft-dirty.rst)
+    * Bit  55    pte is soft-dirty (see Documentation/admin-guide/mm/soft-dirty.rst)
     * Bit  56    page exclusively mapped (since 4.2)
     * Bits 57-60 zero
     * Bit  61    page is file-page or shared-anon (since 3.5)
@@ -97,7 +97,7 @@ Short descriptions to the page flags
     A compound page with order N consists of 2^N physically contiguous pages.
     A compound page with order 2 takes the form of "HTTT", where H donates its
     head page and T donates its tail page(s).  The major consumers of compound
-    pages are hugeTLB pages (Documentation/vm/hugetlbpage.rst), the SLUB etc.
+    pages are hugeTLB pages (Documentation/admin-guide/mm/hugetlbpage.rst), the SLUB etc.
     memory allocators and various device drivers. However in this interface,
     only huge/giga pages are made visible to end users.
 16 - COMPOUND_TAIL
@@ -118,7 +118,7 @@ Short descriptions to the page flags
     zero page for pfn_zero or huge_zero page
 25 - IDLE
     page has not been accessed since it was marked idle (see
-    Documentation/vm/idle_page_tracking.rst). Note that this flag may be
+    Documentation/admin-guide/mm/idle_page_tracking.rst). Note that this flag may be
     stale in case the page was accessed via a PTE. To make sure the flag
     is up-to-date one has to read ``/sys/kernel/mm/page_idle/bitmap`` first.
 
diff --git a/Documentation/vm/soft-dirty.rst b/Documentation/admin-guide/mm/soft-dirty.rst
similarity index 100%
rename from Documentation/vm/soft-dirty.rst
rename to Documentation/admin-guide/mm/soft-dirty.rst
diff --git a/Documentation/vm/userfaultfd.rst b/Documentation/admin-guide/mm/userfaultfd.rst
similarity index 100%
rename from Documentation/vm/userfaultfd.rst
rename to Documentation/admin-guide/mm/userfaultfd.rst
diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 2d3984c..ef53f80 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -515,7 +515,8 @@ guarantees:
 
 The /proc/PID/clear_refs is used to reset the PG_Referenced and ACCESSED/YOUNG
 bits on both physical and virtual pages associated with a process, and the
-soft-dirty bit on pte (see Documentation/vm/soft-dirty.rst for details).
+soft-dirty bit on pte (see Documentation/admin-guide/mm/soft-dirty.rst
+for details).
 To clear the bits for all the pages associated with the process
     > echo 1 > /proc/PID/clear_refs
 
@@ -536,7 +537,8 @@ Any other value written to /proc/PID/clear_refs will have no effect.
 
 The /proc/pid/pagemap gives the PFN, which can be used to find the pageflags
 using /proc/kpageflags and number of times a page is mapped using
-/proc/kpagecount. For detailed explanation, see Documentation/vm/pagemap.rst.
+/proc/kpagecount. For detailed explanation, see
+Documentation/admin-guide/mm/pagemap.rst.
 
 The /proc/pid/numa_maps is an extension based on maps, showing the memory
 locality and binding policy, as well as the memory usage (in pages) of
diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index c8e6d5b..697ef8c 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -515,7 +515,7 @@ nr_hugepages
 
 Change the minimum size of the hugepage pool.
 
-See Documentation/vm/hugetlbpage.rst
+See Documentation/admin-guide/mm/hugetlbpage.rst
 
 ==============================================================
 
@@ -524,7 +524,7 @@ nr_overcommit_hugepages
 Change the maximum size of the hugepage pool. The maximum is
 nr_hugepages + nr_overcommit_hugepages.
 
-See Documentation/vm/hugetlbpage.rst
+See Documentation/admin-guide/mm/hugetlbpage.rst
 
 ==============================================================
 
diff --git a/Documentation/vm/00-INDEX b/Documentation/vm/00-INDEX
index cda564d..f8a96ca 100644
--- a/Documentation/vm/00-INDEX
+++ b/Documentation/vm/00-INDEX
@@ -12,14 +12,10 @@ highmem.rst
 	- Outline of highmem and common issues.
 hmm.rst
 	- Documentation of heterogeneous memory management
-hugetlbpage.rst
-	- a brief summary of hugetlbpage support in the Linux kernel.
 hugetlbfs_reserv.rst
 	- A brief overview of hugetlbfs reservation design/implementation.
 hwpoison.rst
 	- explains what hwpoison is
-idle_page_tracking.rst
-	- description of the idle page tracking feature.
 ksm.rst
 	- how to use the Kernel Samepage Merging feature.
 mmu_notifier.rst
@@ -34,16 +30,12 @@ page_frags.rst
 	- description of page fragments allocator
 page_migration.rst
 	- description of page migration in NUMA systems.
-pagemap.rst
-	- pagemap, from the userspace perspective
 page_owner.rst
 	- tracking about who allocated each page
 remap_file_pages.rst
 	- a note about remap_file_pages() system call
 slub.rst
 	- a short users guide for SLUB.
-soft-dirty.rst
-	- short explanation for soft-dirty PTEs
 split_page_table_lock.rst
 	- Separate per-table lock to improve scalability of the old page_table_lock.
 swap_numa.rst
@@ -52,8 +44,6 @@ transhuge.rst
 	- Transparent Hugepage Support, alternative way of using hugepages.
 unevictable-lru.rst
 	- Unevictable LRU infrastructure
-userfaultfd.rst
-	- description of userfaultfd system call
 z3fold.txt
 	- outline of z3fold allocator for storing compressed pages
 zsmalloc.rst
diff --git a/Documentation/vm/hwpoison.rst b/Documentation/vm/hwpoison.rst
index 070aa1e..09bd24a 100644
--- a/Documentation/vm/hwpoison.rst
+++ b/Documentation/vm/hwpoison.rst
@@ -155,7 +155,7 @@ Testing
 	value).  This allows stress testing of many kinds of
 	pages. The page_flags are the same as in /proc/kpageflags. The
 	flag bits are defined in include/linux/kernel-page-flags.h and
-	documented in Documentation/vm/pagemap.rst
+	documented in Documentation/admin-guide/mm/pagemap.rst
 
 * Architecture specific MCE injector
 
diff --git a/Documentation/vm/index.rst b/Documentation/vm/index.rst
index 6c45142..ed58cb9 100644
--- a/Documentation/vm/index.rst
+++ b/Documentation/vm/index.rst
@@ -13,15 +13,10 @@ various features of the Linux memory management
 .. toctree::
    :maxdepth: 1
 
-   hugetlbpage
-   idle_page_tracking
    ksm
    numa_memory_policy
-   pagemap
    transhuge
-   soft-dirty
    swap_numa
-   userfaultfd
    zswap
 
 Kernel developers MM documentation
diff --git a/fs/Kconfig b/fs/Kconfig
index ba53dc2..ac4ac90 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -196,7 +196,7 @@ config HUGETLBFS
 	help
 	  hugetlbfs is a filesystem backing for HugeTLB pages, based on
 	  ramfs. For architectures that support it, say Y here and read
-	  <file:Documentation/vm/hugetlbpage.rst> for details.
+	  <file:Documentation/admin-guide/mm/hugetlbpage.rst> for details.
 
 	  If unsure, say N.
 
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 333cda8..ed48b6e 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -937,7 +937,7 @@ static inline void clear_soft_dirty(struct vm_area_struct *vma,
 	/*
 	 * The soft-dirty tracker uses #PF-s to catch writes
 	 * to pages, so write-protect the pte as well. See the
-	 * Documentation/vm/soft-dirty.rst for full description
+	 * Documentation/admin-guide/mm/soft-dirty.rst for full description
 	 * of how soft-dirty works.
 	 */
 	pte_t ptent = *pte;
@@ -1417,7 +1417,7 @@ static int pagemap_hugetlb_range(pte_t *ptep, unsigned long hmask,
  * Bits 0-54  page frame number (PFN) if present
  * Bits 0-4   swap type if swapped
  * Bits 5-54  swap offset if swapped
- * Bit  55    pte is soft-dirty (see Documentation/vm/soft-dirty.rst)
+ * Bit  55    pte is soft-dirty (see Documentation/admin-guide/mm/soft-dirty.rst)
  * Bit  56    page exclusively mapped
  * Bits 57-60 zero
  * Bit  61    page is file-page or shared-anon
diff --git a/mm/Kconfig b/mm/Kconfig
index 9bdb018..2d7ef62 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -530,7 +530,7 @@ config MEM_SOFT_DIRTY
 	  into a page just as regular dirty bit, but unlike the latter
 	  it can be cleared by hands.
 
-	  See Documentation/vm/soft-dirty.rst for more details.
+	  See Documentation/admin-guide/mm/soft-dirty.rst for more details.
 
 config ZSWAP
 	bool "Compressed cache for swap pages (EXPERIMENTAL)"
@@ -656,7 +656,8 @@ config IDLE_PAGE_TRACKING
 	  be useful to tune memory cgroup limits and/or for job placement
 	  within a compute cluster.
 
-	  See Documentation/vm/idle_page_tracking.rst for more details.
+	  See Documentation/admin-guide/mm/idle_page_tracking.rst for
+	  more details.
 
 # arch_add_memory() comprehends device memory
 config ARCH_HAS_ZONE_DEVICE
-- 
2.7.4
