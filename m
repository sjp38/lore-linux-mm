Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9F7D96B0289
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:25:35 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id c9so3889764qth.16
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 12:25:35 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id t76si3592903qka.220.2018.03.21.12.25.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 12:25:32 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w2LJPU0p119631
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:25:31 -0400
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2guv66urvn-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 15:25:30 -0400
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 21 Mar 2018 19:25:22 -0000
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 31/32] docs/vm: rename documentation files to .rst
Date: Wed, 21 Mar 2018 21:22:47 +0200
In-Reply-To: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1521660168-14372-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1521660168-14372-32-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Richard Henderson <rth@twiddle.net>, Ivan Kokshaysky <ink@jurassic.park.msu.ru>, Matt Turner <mattst88@gmail.com>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Michael Ellerman <mpe@ellerman.id.au>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, kasan-dev@googlegroups.com, linux-alpha@vger.kernel.org, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 Documentation/ABI/stable/sysfs-devices-node        |  2 +-
 .../ABI/testing/sysfs-kernel-mm-hugepages          |  2 +-
 Documentation/ABI/testing/sysfs-kernel-mm-ksm      |  2 +-
 Documentation/ABI/testing/sysfs-kernel-slab        |  4 +-
 Documentation/admin-guide/kernel-parameters.txt    | 12 ++---
 Documentation/dev-tools/kasan.rst                  |  2 +-
 Documentation/filesystems/proc.txt                 |  4 +-
 Documentation/filesystems/tmpfs.txt                |  2 +-
 Documentation/sysctl/vm.txt                        |  6 +--
 Documentation/vm/00-INDEX                          | 58 +++++++++++-----------
 Documentation/vm/{active_mm.txt => active_mm.rst}  |  0
 Documentation/vm/{balance => balance.rst}          |  0
 .../vm/{cleancache.txt => cleancache.rst}          |  0
 Documentation/vm/{frontswap.txt => frontswap.rst}  |  0
 Documentation/vm/{highmem.txt => highmem.rst}      |  0
 Documentation/vm/{hmm.txt => hmm.rst}              |  0
 .../{hugetlbfs_reserv.txt => hugetlbfs_reserv.rst} |  0
 .../vm/{hugetlbpage.txt => hugetlbpage.rst}        |  2 +-
 Documentation/vm/{hwpoison.txt => hwpoison.rst}    |  2 +-
 ...le_page_tracking.txt => idle_page_tracking.rst} |  2 +-
 Documentation/vm/{ksm.txt => ksm.rst}              |  0
 .../vm/{mmu_notifier.txt => mmu_notifier.rst}      |  0
 Documentation/vm/{numa => numa.rst}                |  2 +-
 ...ma_memory_policy.txt => numa_memory_policy.rst} |  0
 ...commit-accounting => overcommit-accounting.rst} |  0
 Documentation/vm/{page_frags => page_frags.rst}    |  0
 .../vm/{page_migration => page_migration.rst}      |  0
 .../vm/{page_owner.txt => page_owner.rst}          |  0
 Documentation/vm/{pagemap.txt => pagemap.rst}      |  6 +--
 .../{remap_file_pages.txt => remap_file_pages.rst} |  0
 Documentation/vm/{slub.txt => slub.rst}            |  0
 .../vm/{soft-dirty.txt => soft-dirty.rst}          |  0
 ...t_page_table_lock => split_page_table_lock.rst} |  0
 Documentation/vm/{swap_numa.txt => swap_numa.rst}  |  0
 Documentation/vm/{transhuge.txt => transhuge.rst}  |  0
 .../{unevictable-lru.txt => unevictable-lru.rst}   |  0
 .../vm/{userfaultfd.txt => userfaultfd.rst}        |  0
 Documentation/vm/{z3fold.txt => z3fold.rst}        |  0
 Documentation/vm/{zsmalloc.txt => zsmalloc.rst}    |  0
 Documentation/vm/{zswap.txt => zswap.rst}          |  0
 MAINTAINERS                                        |  2 +-
 arch/alpha/Kconfig                                 |  2 +-
 arch/ia64/Kconfig                                  |  2 +-
 arch/mips/Kconfig                                  |  2 +-
 arch/powerpc/Kconfig                               |  2 +-
 fs/Kconfig                                         |  2 +-
 fs/dax.c                                           |  2 +-
 fs/proc/task_mmu.c                                 |  4 +-
 include/linux/hmm.h                                |  2 +-
 include/linux/memremap.h                           |  4 +-
 include/linux/mmu_notifier.h                       |  2 +-
 include/linux/sched/mm.h                           |  4 +-
 include/linux/swap.h                               |  2 +-
 mm/Kconfig                                         |  6 +--
 mm/cleancache.c                                    |  2 +-
 mm/frontswap.c                                     |  2 +-
 mm/hmm.c                                           |  2 +-
 mm/huge_memory.c                                   |  4 +-
 mm/hugetlb.c                                       |  4 +-
 mm/ksm.c                                           |  4 +-
 mm/mmap.c                                          |  2 +-
 mm/rmap.c                                          |  6 +--
 mm/util.c                                          |  2 +-
 63 files changed, 87 insertions(+), 87 deletions(-)
 rename Documentation/vm/{active_mm.txt => active_mm.rst} (100%)
 rename Documentation/vm/{balance => balance.rst} (100%)
 rename Documentation/vm/{cleancache.txt => cleancache.rst} (100%)
 rename Documentation/vm/{frontswap.txt => frontswap.rst} (100%)
 rename Documentation/vm/{highmem.txt => highmem.rst} (100%)
 rename Documentation/vm/{hmm.txt => hmm.rst} (100%)
 rename Documentation/vm/{hugetlbfs_reserv.txt => hugetlbfs_reserv.rst} (100%)
 rename Documentation/vm/{hugetlbpage.txt => hugetlbpage.rst} (99%)
 rename Documentation/vm/{hwpoison.txt => hwpoison.rst} (99%)
 rename Documentation/vm/{idle_page_tracking.txt => idle_page_tracking.rst} (98%)
 rename Documentation/vm/{ksm.txt => ksm.rst} (100%)
 rename Documentation/vm/{mmu_notifier.txt => mmu_notifier.rst} (100%)
 rename Documentation/vm/{numa => numa.rst} (99%)
 rename Documentation/vm/{numa_memory_policy.txt => numa_memory_policy.rst} (100%)
 rename Documentation/vm/{overcommit-accounting => overcommit-accounting.rst} (100%)
 rename Documentation/vm/{page_frags => page_frags.rst} (100%)
 rename Documentation/vm/{page_migration => page_migration.rst} (100%)
 rename Documentation/vm/{page_owner.txt => page_owner.rst} (100%)
 rename Documentation/vm/{pagemap.txt => pagemap.rst} (98%)
 rename Documentation/vm/{remap_file_pages.txt => remap_file_pages.rst} (100%)
 rename Documentation/vm/{slub.txt => slub.rst} (100%)
 rename Documentation/vm/{soft-dirty.txt => soft-dirty.rst} (100%)
 rename Documentation/vm/{split_page_table_lock => split_page_table_lock.rst} (100%)
 rename Documentation/vm/{swap_numa.txt => swap_numa.rst} (100%)
 rename Documentation/vm/{transhuge.txt => transhuge.rst} (100%)
 rename Documentation/vm/{unevictable-lru.txt => unevictable-lru.rst} (100%)
 rename Documentation/vm/{userfaultfd.txt => userfaultfd.rst} (100%)
 rename Documentation/vm/{z3fold.txt => z3fold.rst} (100%)
 rename Documentation/vm/{zsmalloc.txt => zsmalloc.rst} (100%)
 rename Documentation/vm/{zswap.txt => zswap.rst} (100%)

diff --git a/Documentation/ABI/stable/sysfs-devices-node b/Documentation/ABI/stable/sysfs-devices-node
index 5b2d0f0..b38f4b7 100644
--- a/Documentation/ABI/stable/sysfs-devices-node
+++ b/Documentation/ABI/stable/sysfs-devices-node
@@ -90,4 +90,4 @@ Date:		December 2009
 Contact:	Lee Schermerhorn <lee.schermerhorn@hp.com>
 Description:
 		The node's huge page size control/query attributes.
-		See Documentation/vm/hugetlbpage.txt
\ No newline at end of file
+		See Documentation/vm/hugetlbpage.rst
\ No newline at end of file
diff --git a/Documentation/ABI/testing/sysfs-kernel-mm-hugepages b/Documentation/ABI/testing/sysfs-kernel-mm-hugepages
index e21c005..5140b23 100644
--- a/Documentation/ABI/testing/sysfs-kernel-mm-hugepages
+++ b/Documentation/ABI/testing/sysfs-kernel-mm-hugepages
@@ -12,4 +12,4 @@ Description:
 			free_hugepages
 			surplus_hugepages
 			resv_hugepages
-		See Documentation/vm/hugetlbpage.txt for details.
+		See Documentation/vm/hugetlbpage.rst for details.
diff --git a/Documentation/ABI/testing/sysfs-kernel-mm-ksm b/Documentation/ABI/testing/sysfs-kernel-mm-ksm
index 73e653e..dfc1324 100644
--- a/Documentation/ABI/testing/sysfs-kernel-mm-ksm
+++ b/Documentation/ABI/testing/sysfs-kernel-mm-ksm
@@ -40,7 +40,7 @@ Description:	Kernel Samepage Merging daemon sysfs interface
 		sleep_millisecs: how many milliseconds ksm should sleep between
 		scans.
 
-		See Documentation/vm/ksm.txt for more information.
+		See Documentation/vm/ksm.rst for more information.
 
 What:		/sys/kernel/mm/ksm/merge_across_nodes
 Date:		January 2013
diff --git a/Documentation/ABI/testing/sysfs-kernel-slab b/Documentation/ABI/testing/sysfs-kernel-slab
index 2cc0a72..29601d9 100644
--- a/Documentation/ABI/testing/sysfs-kernel-slab
+++ b/Documentation/ABI/testing/sysfs-kernel-slab
@@ -37,7 +37,7 @@ Description:
 		The alloc_calls file is read-only and lists the kernel code
 		locations from which allocations for this cache were performed.
 		The alloc_calls file only contains information if debugging is
-		enabled for that cache (see Documentation/vm/slub.txt).
+		enabled for that cache (see Documentation/vm/slub.rst).
 
 What:		/sys/kernel/slab/cache/alloc_fastpath
 Date:		February 2008
@@ -219,7 +219,7 @@ Contact:	Pekka Enberg <penberg@cs.helsinki.fi>,
 Description:
 		The free_calls file is read-only and lists the locations of
 		object frees if slab debugging is enabled (see
-		Documentation/vm/slub.txt).
+		Documentation/vm/slub.rst).
 
 What:		/sys/kernel/slab/cache/free_fastpath
 Date:		February 2008
diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index 1d1d53f..5d6e550 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -3887,7 +3887,7 @@
 			cache (risks via metadata attacks are mostly
 			unchanged). Debug options disable merging on their
 			own.
-			For more information see Documentation/vm/slub.txt.
+			For more information see Documentation/vm/slub.rst.
 
 	slab_max_order=	[MM, SLAB]
 			Determines the maximum allowed order for slabs.
@@ -3901,7 +3901,7 @@
 			slub_debug can create guard zones around objects and
 			may poison objects when not in use. Also tracks the
 			last alloc / free. For more information see
-			Documentation/vm/slub.txt.
+			Documentation/vm/slub.rst.
 
 	slub_memcg_sysfs=	[MM, SLUB]
 			Determines whether to enable sysfs directories for
@@ -3915,7 +3915,7 @@
 			Determines the maximum allowed order for slabs.
 			A high setting may cause OOMs due to memory
 			fragmentation. For more information see
-			Documentation/vm/slub.txt.
+			Documentation/vm/slub.rst.
 
 	slub_min_objects=	[MM, SLUB]
 			The minimum number of objects per slab. SLUB will
@@ -3924,12 +3924,12 @@
 			the number of objects indicated. The higher the number
 			of objects the smaller the overhead of tracking slabs
 			and the less frequently locks need to be acquired.
-			For more information see Documentation/vm/slub.txt.
+			For more information see Documentation/vm/slub.rst.
 
 	slub_min_order=	[MM, SLUB]
 			Determines the minimum page order for slabs. Must be
 			lower than slub_max_order.
-			For more information see Documentation/vm/slub.txt.
+			For more information see Documentation/vm/slub.rst.
 
 	slub_nomerge	[MM, SLUB]
 			Same with slab_nomerge. This is supported for legacy.
@@ -4285,7 +4285,7 @@
 			Format: [always|madvise|never]
 			Can be used to control the default behavior of the system
 			with respect to transparent hugepages.
-			See Documentation/vm/transhuge.txt for more details.
+			See Documentation/vm/transhuge.rst for more details.
 
 	tsc=		Disable clocksource stability checks for TSC.
 			Format: <string>
diff --git a/Documentation/dev-tools/kasan.rst b/Documentation/dev-tools/kasan.rst
index f7a18f2..aabc873 100644
--- a/Documentation/dev-tools/kasan.rst
+++ b/Documentation/dev-tools/kasan.rst
@@ -120,7 +120,7 @@ A typical out of bounds access report looks like this::
 
 The header of the report discribe what kind of bug happened and what kind of
 access caused it. It's followed by the description of the accessed slub object
-(see 'SLUB Debug output' section in Documentation/vm/slub.txt for details) and
+(see 'SLUB Debug output' section in Documentation/vm/slub.rst for details) and
 the description of the accessed memory page.
 
 In the last section the report shows memory state around the accessed address.
diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 2a84bb3..2d3984c 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -515,7 +515,7 @@ guarantees:
 
 The /proc/PID/clear_refs is used to reset the PG_Referenced and ACCESSED/YOUNG
 bits on both physical and virtual pages associated with a process, and the
-soft-dirty bit on pte (see Documentation/vm/soft-dirty.txt for details).
+soft-dirty bit on pte (see Documentation/vm/soft-dirty.rst for details).
 To clear the bits for all the pages associated with the process
     > echo 1 > /proc/PID/clear_refs
 
@@ -536,7 +536,7 @@ Any other value written to /proc/PID/clear_refs will have no effect.
 
 The /proc/pid/pagemap gives the PFN, which can be used to find the pageflags
 using /proc/kpageflags and number of times a page is mapped using
-/proc/kpagecount. For detailed explanation, see Documentation/vm/pagemap.txt.
+/proc/kpagecount. For detailed explanation, see Documentation/vm/pagemap.rst.
 
 The /proc/pid/numa_maps is an extension based on maps, showing the memory
 locality and binding policy, as well as the memory usage (in pages) of
diff --git a/Documentation/filesystems/tmpfs.txt b/Documentation/filesystems/tmpfs.txt
index a85355c..627389a 100644
--- a/Documentation/filesystems/tmpfs.txt
+++ b/Documentation/filesystems/tmpfs.txt
@@ -105,7 +105,7 @@ policy for the file will revert to "default" policy.
 NUMA memory allocation policies have optional flags that can be used in
 conjunction with their modes.  These optional flags can be specified
 when tmpfs is mounted by appending them to the mode before the NodeList.
-See Documentation/vm/numa_memory_policy.txt for a list of all available
+See Documentation/vm/numa_memory_policy.rst for a list of all available
 memory allocation policy mode flags and their effect on memory policy.
 
 	=static		is equivalent to	MPOL_F_STATIC_NODES
diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index ff234d2..ef581a9 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -516,7 +516,7 @@ nr_hugepages
 
 Change the minimum size of the hugepage pool.
 
-See Documentation/vm/hugetlbpage.txt
+See Documentation/vm/hugetlbpage.rst
 
 ==============================================================
 
@@ -525,7 +525,7 @@ nr_overcommit_hugepages
 Change the maximum size of the hugepage pool. The maximum is
 nr_hugepages + nr_overcommit_hugepages.
 
-See Documentation/vm/hugetlbpage.txt
+See Documentation/vm/hugetlbpage.rst
 
 ==============================================================
 
@@ -668,7 +668,7 @@ and don't use much of it.
 
 The default value is 0.
 
-See Documentation/vm/overcommit-accounting and
+See Documentation/vm/overcommit-accounting.rst and
 mm/mmap.c::__vm_enough_memory() for more information.
 
 ==============================================================
diff --git a/Documentation/vm/00-INDEX b/Documentation/vm/00-INDEX
index 0278f2c..cda564d 100644
--- a/Documentation/vm/00-INDEX
+++ b/Documentation/vm/00-INDEX
@@ -1,62 +1,62 @@
 00-INDEX
 	- this file.
-active_mm.txt
+active_mm.rst
 	- An explanation from Linus about tsk->active_mm vs tsk->mm.
-balance
+balance.rst
 	- various information on memory balancing.
-cleancache.txt
+cleancache.rst
 	- Intro to cleancache and page-granularity victim cache.
-frontswap.txt
+frontswap.rst
 	- Outline frontswap, part of the transcendent memory frontend.
-highmem.txt
+highmem.rst
 	- Outline of highmem and common issues.
-hmm.txt
+hmm.rst
 	- Documentation of heterogeneous memory management
-hugetlbpage.txt
+hugetlbpage.rst
 	- a brief summary of hugetlbpage support in the Linux kernel.
-hugetlbfs_reserv.txt
+hugetlbfs_reserv.rst
 	- A brief overview of hugetlbfs reservation design/implementation.
-hwpoison.txt
+hwpoison.rst
 	- explains what hwpoison is
-idle_page_tracking.txt
+idle_page_tracking.rst
 	- description of the idle page tracking feature.
-ksm.txt
+ksm.rst
 	- how to use the Kernel Samepage Merging feature.
-mmu_notifier.txt
+mmu_notifier.rst
 	- a note about clearing pte/pmd and mmu notifications
-numa
+numa.rst
 	- information about NUMA specific code in the Linux vm.
-numa_memory_policy.txt
+numa_memory_policy.rst
 	- documentation of concepts and APIs of the 2.6 memory policy support.
-overcommit-accounting
+overcommit-accounting.rst
 	- description of the Linux kernels overcommit handling modes.
-page_frags
+page_frags.rst
 	- description of page fragments allocator
-page_migration
+page_migration.rst
 	- description of page migration in NUMA systems.
-pagemap.txt
+pagemap.rst
 	- pagemap, from the userspace perspective
-page_owner.txt
+page_owner.rst
 	- tracking about who allocated each page
-remap_file_pages.txt
+remap_file_pages.rst
 	- a note about remap_file_pages() system call
-slub.txt
+slub.rst
 	- a short users guide for SLUB.
-soft-dirty.txt
+soft-dirty.rst
 	- short explanation for soft-dirty PTEs
-split_page_table_lock
+split_page_table_lock.rst
 	- Separate per-table lock to improve scalability of the old page_table_lock.
-swap_numa.txt
+swap_numa.rst
 	- automatic binding of swap device to numa node
-transhuge.txt
+transhuge.rst
 	- Transparent Hugepage Support, alternative way of using hugepages.
-unevictable-lru.txt
+unevictable-lru.rst
 	- Unevictable LRU infrastructure
-userfaultfd.txt
+userfaultfd.rst
 	- description of userfaultfd system call
 z3fold.txt
 	- outline of z3fold allocator for storing compressed pages
-zsmalloc.txt
+zsmalloc.rst
 	- outline of zsmalloc allocator for storing compressed pages
-zswap.txt
+zswap.rst
 	- Intro to compressed cache for swap pages
diff --git a/Documentation/vm/active_mm.txt b/Documentation/vm/active_mm.rst
similarity index 100%
rename from Documentation/vm/active_mm.txt
rename to Documentation/vm/active_mm.rst
diff --git a/Documentation/vm/balance b/Documentation/vm/balance.rst
similarity index 100%
rename from Documentation/vm/balance
rename to Documentation/vm/balance.rst
diff --git a/Documentation/vm/cleancache.txt b/Documentation/vm/cleancache.rst
similarity index 100%
rename from Documentation/vm/cleancache.txt
rename to Documentation/vm/cleancache.rst
diff --git a/Documentation/vm/frontswap.txt b/Documentation/vm/frontswap.rst
similarity index 100%
rename from Documentation/vm/frontswap.txt
rename to Documentation/vm/frontswap.rst
diff --git a/Documentation/vm/highmem.txt b/Documentation/vm/highmem.rst
similarity index 100%
rename from Documentation/vm/highmem.txt
rename to Documentation/vm/highmem.rst
diff --git a/Documentation/vm/hmm.txt b/Documentation/vm/hmm.rst
similarity index 100%
rename from Documentation/vm/hmm.txt
rename to Documentation/vm/hmm.rst
diff --git a/Documentation/vm/hugetlbfs_reserv.txt b/Documentation/vm/hugetlbfs_reserv.rst
similarity index 100%
rename from Documentation/vm/hugetlbfs_reserv.txt
rename to Documentation/vm/hugetlbfs_reserv.rst
diff --git a/Documentation/vm/hugetlbpage.txt b/Documentation/vm/hugetlbpage.rst
similarity index 99%
rename from Documentation/vm/hugetlbpage.txt
rename to Documentation/vm/hugetlbpage.rst
index 3bb0d99..a5da14b 100644
--- a/Documentation/vm/hugetlbpage.txt
+++ b/Documentation/vm/hugetlbpage.rst
@@ -217,7 +217,7 @@ When adjusting the persistent hugepage count via ``nr_hugepages_mempolicy``, any
 memory policy mode--bind, preferred, local or interleave--may be used.  The
 resulting effect on persistent huge page allocation is as follows:
 
-#. Regardless of mempolicy mode [see Documentation/vm/numa_memory_policy.txt],
+#. Regardless of mempolicy mode [see Documentation/vm/numa_memory_policy.rst],
    persistent huge pages will be distributed across the node or nodes
    specified in the mempolicy as if "interleave" had been specified.
    However, if a node in the policy does not contain sufficient contiguous
diff --git a/Documentation/vm/hwpoison.txt b/Documentation/vm/hwpoison.rst
similarity index 99%
rename from Documentation/vm/hwpoison.txt
rename to Documentation/vm/hwpoison.rst
index b1a8c24..070aa1e 100644
--- a/Documentation/vm/hwpoison.txt
+++ b/Documentation/vm/hwpoison.rst
@@ -155,7 +155,7 @@ Testing
 	value).  This allows stress testing of many kinds of
 	pages. The page_flags are the same as in /proc/kpageflags. The
 	flag bits are defined in include/linux/kernel-page-flags.h and
-	documented in Documentation/vm/pagemap.txt
+	documented in Documentation/vm/pagemap.rst
 
 * Architecture specific MCE injector
 
diff --git a/Documentation/vm/idle_page_tracking.txt b/Documentation/vm/idle_page_tracking.rst
similarity index 98%
rename from Documentation/vm/idle_page_tracking.txt
rename to Documentation/vm/idle_page_tracking.rst
index 9cbe6f8..d1c4609 100644
--- a/Documentation/vm/idle_page_tracking.txt
+++ b/Documentation/vm/idle_page_tracking.rst
@@ -65,7 +65,7 @@ workload one should:
     are not reclaimable, he or she can filter them out using
     ``/proc/kpageflags``.
 
-See Documentation/vm/pagemap.txt for more information about
+See Documentation/vm/pagemap.rst for more information about
 ``/proc/pid/pagemap``, ``/proc/kpageflags``, and ``/proc/kpagecgroup``.
 
 .. _impl_details:
diff --git a/Documentation/vm/ksm.txt b/Documentation/vm/ksm.rst
similarity index 100%
rename from Documentation/vm/ksm.txt
rename to Documentation/vm/ksm.rst
diff --git a/Documentation/vm/mmu_notifier.txt b/Documentation/vm/mmu_notifier.rst
similarity index 100%
rename from Documentation/vm/mmu_notifier.txt
rename to Documentation/vm/mmu_notifier.rst
diff --git a/Documentation/vm/numa b/Documentation/vm/numa.rst
similarity index 99%
rename from Documentation/vm/numa
rename to Documentation/vm/numa.rst
index c81e7c5..aada84b 100644
--- a/Documentation/vm/numa
+++ b/Documentation/vm/numa.rst
@@ -110,7 +110,7 @@ to improve NUMA locality using various CPU affinity command line interfaces,
 such as taskset(1) and numactl(1), and program interfaces such as
 sched_setaffinity(2).  Further, one can modify the kernel's default local
 allocation behavior using Linux NUMA memory policy.
-[see Documentation/vm/numa_memory_policy.txt.]
+[see Documentation/vm/numa_memory_policy.rst.]
 
 System administrators can restrict the CPUs and nodes' memories that a non-
 privileged user can specify in the scheduling or NUMA commands and functions
diff --git a/Documentation/vm/numa_memory_policy.txt b/Documentation/vm/numa_memory_policy.rst
similarity index 100%
rename from Documentation/vm/numa_memory_policy.txt
rename to Documentation/vm/numa_memory_policy.rst
diff --git a/Documentation/vm/overcommit-accounting b/Documentation/vm/overcommit-accounting.rst
similarity index 100%
rename from Documentation/vm/overcommit-accounting
rename to Documentation/vm/overcommit-accounting.rst
diff --git a/Documentation/vm/page_frags b/Documentation/vm/page_frags.rst
similarity index 100%
rename from Documentation/vm/page_frags
rename to Documentation/vm/page_frags.rst
diff --git a/Documentation/vm/page_migration b/Documentation/vm/page_migration.rst
similarity index 100%
rename from Documentation/vm/page_migration
rename to Documentation/vm/page_migration.rst
diff --git a/Documentation/vm/page_owner.txt b/Documentation/vm/page_owner.rst
similarity index 100%
rename from Documentation/vm/page_owner.txt
rename to Documentation/vm/page_owner.rst
diff --git a/Documentation/vm/pagemap.txt b/Documentation/vm/pagemap.rst
similarity index 98%
rename from Documentation/vm/pagemap.txt
rename to Documentation/vm/pagemap.rst
index bd6d717..d54b4bf 100644
--- a/Documentation/vm/pagemap.txt
+++ b/Documentation/vm/pagemap.rst
@@ -18,7 +18,7 @@ There are four components to pagemap:
     * Bits 0-54  page frame number (PFN) if present
     * Bits 0-4   swap type if swapped
     * Bits 5-54  swap offset if swapped
-    * Bit  55    pte is soft-dirty (see Documentation/vm/soft-dirty.txt)
+    * Bit  55    pte is soft-dirty (see Documentation/vm/soft-dirty.rst)
     * Bit  56    page exclusively mapped (since 4.2)
     * Bits 57-60 zero
     * Bit  61    page is file-page or shared-anon (since 3.5)
@@ -97,7 +97,7 @@ Short descriptions to the page flags:
     A compound page with order N consists of 2^N physically contiguous pages.
     A compound page with order 2 takes the form of "HTTT", where H donates its
     head page and T donates its tail page(s).  The major consumers of compound
-    pages are hugeTLB pages (Documentation/vm/hugetlbpage.txt), the SLUB etc.
+    pages are hugeTLB pages (Documentation/vm/hugetlbpage.rst), the SLUB etc.
     memory allocators and various device drivers. However in this interface,
     only huge/giga pages are made visible to end users.
 16 - COMPOUND_TAIL
@@ -118,7 +118,7 @@ Short descriptions to the page flags:
     zero page for pfn_zero or huge_zero page
 25 - IDLE
     page has not been accessed since it was marked idle (see
-    Documentation/vm/idle_page_tracking.txt). Note that this flag may be
+    Documentation/vm/idle_page_tracking.rst). Note that this flag may be
     stale in case the page was accessed via a PTE. To make sure the flag
     is up-to-date one has to read ``/sys/kernel/mm/page_idle/bitmap`` first.
 
diff --git a/Documentation/vm/remap_file_pages.txt b/Documentation/vm/remap_file_pages.rst
similarity index 100%
rename from Documentation/vm/remap_file_pages.txt
rename to Documentation/vm/remap_file_pages.rst
diff --git a/Documentation/vm/slub.txt b/Documentation/vm/slub.rst
similarity index 100%
rename from Documentation/vm/slub.txt
rename to Documentation/vm/slub.rst
diff --git a/Documentation/vm/soft-dirty.txt b/Documentation/vm/soft-dirty.rst
similarity index 100%
rename from Documentation/vm/soft-dirty.txt
rename to Documentation/vm/soft-dirty.rst
diff --git a/Documentation/vm/split_page_table_lock b/Documentation/vm/split_page_table_lock.rst
similarity index 100%
rename from Documentation/vm/split_page_table_lock
rename to Documentation/vm/split_page_table_lock.rst
diff --git a/Documentation/vm/swap_numa.txt b/Documentation/vm/swap_numa.rst
similarity index 100%
rename from Documentation/vm/swap_numa.txt
rename to Documentation/vm/swap_numa.rst
diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.rst
similarity index 100%
rename from Documentation/vm/transhuge.txt
rename to Documentation/vm/transhuge.rst
diff --git a/Documentation/vm/unevictable-lru.txt b/Documentation/vm/unevictable-lru.rst
similarity index 100%
rename from Documentation/vm/unevictable-lru.txt
rename to Documentation/vm/unevictable-lru.rst
diff --git a/Documentation/vm/userfaultfd.txt b/Documentation/vm/userfaultfd.rst
similarity index 100%
rename from Documentation/vm/userfaultfd.txt
rename to Documentation/vm/userfaultfd.rst
diff --git a/Documentation/vm/z3fold.txt b/Documentation/vm/z3fold.rst
similarity index 100%
rename from Documentation/vm/z3fold.txt
rename to Documentation/vm/z3fold.rst
diff --git a/Documentation/vm/zsmalloc.txt b/Documentation/vm/zsmalloc.rst
similarity index 100%
rename from Documentation/vm/zsmalloc.txt
rename to Documentation/vm/zsmalloc.rst
diff --git a/Documentation/vm/zswap.txt b/Documentation/vm/zswap.rst
similarity index 100%
rename from Documentation/vm/zswap.txt
rename to Documentation/vm/zswap.rst
diff --git a/MAINTAINERS b/MAINTAINERS
index 4e62756..9dcf431 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -15431,7 +15431,7 @@ L:	linux-mm@kvack.org
 S:	Maintained
 F:	mm/zsmalloc.c
 F:	include/linux/zsmalloc.h
-F:	Documentation/vm/zsmalloc.txt
+F:	Documentation/vm/zsmalloc.rst
 
 ZSWAP COMPRESSED SWAP CACHING
 M:	Seth Jennings <sjenning@redhat.com>
diff --git a/arch/alpha/Kconfig b/arch/alpha/Kconfig
index e96adcb..f53e506 100644
--- a/arch/alpha/Kconfig
+++ b/arch/alpha/Kconfig
@@ -584,7 +584,7 @@ config ARCH_DISCONTIGMEM_ENABLE
 	  Say Y to support efficient handling of discontiguous physical memory,
 	  for architectures which are either NUMA (Non-Uniform Memory Access)
 	  or have huge holes in the physical address space for other reasons.
-	  See <file:Documentation/vm/numa> for more.
+	  See <file:Documentation/vm/numa.rst> for more.
 
 source "mm/Kconfig"
 
diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index bbe12a0..3ac9bf4 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -397,7 +397,7 @@ config ARCH_DISCONTIGMEM_ENABLE
 	  Say Y to support efficient handling of discontiguous physical memory,
 	  for architectures which are either NUMA (Non-Uniform Memory Access)
 	  or have huge holes in the physical address space for other reasons.
- 	  See <file:Documentation/vm/numa> for more.
+	  See <file:Documentation/vm/numa.rst> for more.
 
 config ARCH_FLATMEM_ENABLE
 	def_bool y
diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
index 8128c3b..4562810 100644
--- a/arch/mips/Kconfig
+++ b/arch/mips/Kconfig
@@ -2551,7 +2551,7 @@ config ARCH_DISCONTIGMEM_ENABLE
 	  Say Y to support efficient handling of discontiguous physical memory,
 	  for architectures which are either NUMA (Non-Uniform Memory Access)
 	  or have huge holes in the physical address space for other reasons.
-	  See <file:Documentation/vm/numa> for more.
+	  See <file:Documentation/vm/numa.rst> for more.
 
 config ARCH_SPARSEMEM_ENABLE
 	bool
diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 73ce5dd..f8c0f10 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -880,7 +880,7 @@ config PPC_MEM_KEYS
 	  page-based protections, but without requiring modification of the
 	  page tables when an application changes protection domains.
 
-	  For details, see Documentation/vm/protection-keys.txt
+	  For details, see Documentation/vm/protection-keys.rst
 
 	  If unsure, say y.
 
diff --git a/fs/Kconfig b/fs/Kconfig
index bc821a8..ba53dc2 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -196,7 +196,7 @@ config HUGETLBFS
 	help
 	  hugetlbfs is a filesystem backing for HugeTLB pages, based on
 	  ramfs. For architectures that support it, say Y here and read
-	  <file:Documentation/vm/hugetlbpage.txt> for details.
+	  <file:Documentation/vm/hugetlbpage.rst> for details.
 
 	  If unsure, say N.
 
diff --git a/fs/dax.c b/fs/dax.c
index 0276df9..0eb65c3 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -618,7 +618,7 @@ static void dax_mapping_entry_mkclean(struct address_space *mapping,
 		 * downgrading page table protection not changing it to point
 		 * to a new page.
 		 *
-		 * See Documentation/vm/mmu_notifier.txt
+		 * See Documentation/vm/mmu_notifier.rst
 		 */
 		if (pmdp) {
 #ifdef CONFIG_FS_DAX_PMD
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index ec6d298..91d14c4a 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -956,7 +956,7 @@ static inline void clear_soft_dirty(struct vm_area_struct *vma,
 	/*
 	 * The soft-dirty tracker uses #PF-s to catch writes
 	 * to pages, so write-protect the pte as well. See the
-	 * Documentation/vm/soft-dirty.txt for full description
+	 * Documentation/vm/soft-dirty.rst for full description
 	 * of how soft-dirty works.
 	 */
 	pte_t ptent = *pte;
@@ -1436,7 +1436,7 @@ static int pagemap_hugetlb_range(pte_t *ptep, unsigned long hmask,
  * Bits 0-54  page frame number (PFN) if present
  * Bits 0-4   swap type if swapped
  * Bits 5-54  swap offset if swapped
- * Bit  55    pte is soft-dirty (see Documentation/vm/soft-dirty.txt)
+ * Bit  55    pte is soft-dirty (see Documentation/vm/soft-dirty.rst)
  * Bit  56    page exclusively mapped
  * Bits 57-60 zero
  * Bit  61    page is file-page or shared-anon
diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 325017a..77be87c 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -16,7 +16,7 @@
 /*
  * Heterogeneous Memory Management (HMM)
  *
- * See Documentation/vm/hmm.txt for reasons and overview of what HMM is and it
+ * See Documentation/vm/hmm.rst for reasons and overview of what HMM is and it
  * is for. Here we focus on the HMM API description, with some explanation of
  * the underlying implementation.
  *
diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 7b4899c..74ea5e2 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -45,7 +45,7 @@ struct vmem_altmap {
  * must be treated as an opaque object, rather than a "normal" struct page.
  *
  * A more complete discussion of unaddressable memory may be found in
- * include/linux/hmm.h and Documentation/vm/hmm.txt.
+ * include/linux/hmm.h and Documentation/vm/hmm.rst.
  *
  * MEMORY_DEVICE_PUBLIC:
  * Device memory that is cache coherent from device and CPU point of view. This
@@ -67,7 +67,7 @@ enum memory_type {
  *   page_free()
  *
  * Additional notes about MEMORY_DEVICE_PRIVATE may be found in
- * include/linux/hmm.h and Documentation/vm/hmm.txt. There is also a brief
+ * include/linux/hmm.h and Documentation/vm/hmm.rst. There is also a brief
  * explanation in include/linux/memory_hotplug.h.
  *
  * The page_fault() callback must migrate page back, from device memory to
diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 2d07a1e..392e6af 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -174,7 +174,7 @@ struct mmu_notifier_ops {
 	 * invalidate_range_start()/end() notifiers, as
 	 * invalidate_range() alread catches the points in time when an
 	 * external TLB range needs to be flushed. For more in depth
-	 * discussion on this see Documentation/vm/mmu_notifier.txt
+	 * discussion on this see Documentation/vm/mmu_notifier.rst
 	 *
 	 * Note that this function might be called with just a sub-range
 	 * of what was passed to invalidate_range_start()/end(), if
diff --git a/include/linux/sched/mm.h b/include/linux/sched/mm.h
index 9806184..5837192 100644
--- a/include/linux/sched/mm.h
+++ b/include/linux/sched/mm.h
@@ -28,7 +28,7 @@ extern struct mm_struct *mm_alloc(void);
  *
  * Use mmdrop() to release the reference acquired by mmgrab().
  *
- * See also <Documentation/vm/active_mm.txt> for an in-depth explanation
+ * See also <Documentation/vm/active_mm.rst> for an in-depth explanation
  * of &mm_struct.mm_count vs &mm_struct.mm_users.
  */
 static inline void mmgrab(struct mm_struct *mm)
@@ -62,7 +62,7 @@ static inline void mmdrop(struct mm_struct *mm)
  *
  * Use mmput() to release the reference acquired by mmget().
  *
- * See also <Documentation/vm/active_mm.txt> for an in-depth explanation
+ * See also <Documentation/vm/active_mm.rst> for an in-depth explanation
  * of &mm_struct.mm_count vs &mm_struct.mm_users.
  */
 static inline void mmget(struct mm_struct *mm)
diff --git a/include/linux/swap.h b/include/linux/swap.h
index a1a3f4e..4598fc7 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -53,7 +53,7 @@ static inline int current_is_kswapd(void)
 
 /*
  * Unaddressable device memory support. See include/linux/hmm.h and
- * Documentation/vm/hmm.txt. Short description is we need struct pages for
+ * Documentation/vm/hmm.rst. Short description is we need struct pages for
  * device memory that is unaddressable (inaccessible) by CPU, so that we can
  * migrate part of a process memory to device memory.
  *
diff --git a/mm/Kconfig b/mm/Kconfig
index c782e8f..b9f0421 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -312,7 +312,7 @@ config KSM
 	  the many instances by a single page with that content, so
 	  saving memory until one or another app needs to modify the content.
 	  Recommended for use with KVM, or with other duplicative applications.
-	  See Documentation/vm/ksm.txt for more information: KSM is inactive
+	  See Documentation/vm/ksm.rst for more information: KSM is inactive
 	  until a program has madvised that an area is MADV_MERGEABLE, and
 	  root has set /sys/kernel/mm/ksm/run to 1 (if CONFIG_SYSFS is set).
 
@@ -537,7 +537,7 @@ config MEM_SOFT_DIRTY
 	  into a page just as regular dirty bit, but unlike the latter
 	  it can be cleared by hands.
 
-	  See Documentation/vm/soft-dirty.txt for more details.
+	  See Documentation/vm/soft-dirty.rst for more details.
 
 config ZSWAP
 	bool "Compressed cache for swap pages (EXPERIMENTAL)"
@@ -664,7 +664,7 @@ config IDLE_PAGE_TRACKING
 	  be useful to tune memory cgroup limits and/or for job placement
 	  within a compute cluster.
 
-	  See Documentation/vm/idle_page_tracking.txt for more details.
+	  See Documentation/vm/idle_page_tracking.rst for more details.
 
 # arch_add_memory() comprehends device memory
 config ARCH_HAS_ZONE_DEVICE
diff --git a/mm/cleancache.c b/mm/cleancache.c
index f7b9fdc..126548b 100644
--- a/mm/cleancache.c
+++ b/mm/cleancache.c
@@ -3,7 +3,7 @@
  *
  * This code provides the generic "frontend" layer to call a matching
  * "backend" driver implementation of cleancache.  See
- * Documentation/vm/cleancache.txt for more information.
+ * Documentation/vm/cleancache.rst for more information.
  *
  * Copyright (C) 2009-2010 Oracle Corp. All rights reserved.
  * Author: Dan Magenheimer
diff --git a/mm/frontswap.c b/mm/frontswap.c
index fec8b50..4f5476a 100644
--- a/mm/frontswap.c
+++ b/mm/frontswap.c
@@ -3,7 +3,7 @@
  *
  * This code provides the generic "frontend" layer to call a matching
  * "backend" driver implementation of frontswap.  See
- * Documentation/vm/frontswap.txt for more information.
+ * Documentation/vm/frontswap.rst for more information.
  *
  * Copyright (C) 2009-2012 Oracle Corp.  All rights reserved.
  * Author: Dan Magenheimer
diff --git a/mm/hmm.c b/mm/hmm.c
index 320545b98..af176c6 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -37,7 +37,7 @@
 
 #if defined(CONFIG_DEVICE_PRIVATE) || defined(CONFIG_DEVICE_PUBLIC)
 /*
- * Device private memory see HMM (Documentation/vm/hmm.txt) or hmm.h
+ * Device private memory see HMM (Documentation/vm/hmm.rst) or hmm.h
  */
 DEFINE_STATIC_KEY_FALSE(device_private_key);
 EXPORT_SYMBOL(device_private_key);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 87ab9b8..6d59116 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1185,7 +1185,7 @@ static int do_huge_pmd_wp_page_fallback(struct vm_fault *vmf, pmd_t orig_pmd,
 	 * mmu_notifier_invalidate_range_end() happens which can lead to a
 	 * device seeing memory write in different order than CPU.
 	 *
-	 * See Documentation/vm/mmu_notifier.txt
+	 * See Documentation/vm/mmu_notifier.rst
 	 */
 	pmdp_huge_clear_flush_notify(vma, haddr, vmf->pmd);
 
@@ -2037,7 +2037,7 @@ static void __split_huge_zero_page_pmd(struct vm_area_struct *vma,
 	 * replacing a zero pmd write protected page with a zero pte write
 	 * protected page.
 	 *
-	 * See Documentation/vm/mmu_notifier.txt
+	 * See Documentation/vm/mmu_notifier.rst
 	 */
 	pmdp_huge_clear_flush(vma, haddr, pmd);
 
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index a963f20..1e47698 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3289,7 +3289,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 				 * table protection not changing it to point
 				 * to a new page.
 				 *
-				 * See Documentation/vm/mmu_notifier.txt
+				 * See Documentation/vm/mmu_notifier.rst
 				 */
 				huge_ptep_set_wrprotect(src, addr, src_pte);
 			}
@@ -4355,7 +4355,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
 	 * No need to call mmu_notifier_invalidate_range() we are downgrading
 	 * page table protection not changing it to point to a new page.
 	 *
-	 * See Documentation/vm/mmu_notifier.txt
+	 * See Documentation/vm/mmu_notifier.rst
 	 */
 	i_mmap_unlock_write(vma->vm_file->f_mapping);
 	mmu_notifier_invalidate_range_end(mm, start, end);
diff --git a/mm/ksm.c b/mm/ksm.c
index 293721f..0b88698 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1049,7 +1049,7 @@ static int write_protect_page(struct vm_area_struct *vma, struct page *page,
 		 * No need to notify as we are downgrading page table to read
 		 * only not changing it to point to a new page.
 		 *
-		 * See Documentation/vm/mmu_notifier.txt
+		 * See Documentation/vm/mmu_notifier.rst
 		 */
 		entry = ptep_clear_flush(vma, pvmw.address, pvmw.pte);
 		/*
@@ -1138,7 +1138,7 @@ static int replace_page(struct vm_area_struct *vma, struct page *page,
 	 * No need to notify as we are replacing a read only page with another
 	 * read only page with the same content.
 	 *
-	 * See Documentation/vm/mmu_notifier.txt
+	 * See Documentation/vm/mmu_notifier.rst
 	 */
 	ptep_clear_flush(vma, addr, ptep);
 	set_pte_at_notify(mm, addr, ptep, newpte);
diff --git a/mm/mmap.c b/mm/mmap.c
index 9efdc021..39fc51d 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2769,7 +2769,7 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 	unsigned long ret = -EINVAL;
 	struct file *file;
 
-	pr_warn_once("%s (%d) uses deprecated remap_file_pages() syscall. See Documentation/vm/remap_file_pages.txt.\n",
+	pr_warn_once("%s (%d) uses deprecated remap_file_pages() syscall. See Documentation/vm/remap_file_pages.rst.\n",
 		     current->comm, current->pid);
 
 	if (prot)
diff --git a/mm/rmap.c b/mm/rmap.c
index 47db27f..854b703 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -942,7 +942,7 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 		 * downgrading page table protection not changing it to point
 		 * to a new page.
 		 *
-		 * See Documentation/vm/mmu_notifier.txt
+		 * See Documentation/vm/mmu_notifier.rst
 		 */
 		if (ret)
 			(*cleaned)++;
@@ -1587,7 +1587,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 			 * point at new page while a device still is using this
 			 * page.
 			 *
-			 * See Documentation/vm/mmu_notifier.txt
+			 * See Documentation/vm/mmu_notifier.rst
 			 */
 			dec_mm_counter(mm, mm_counter_file(page));
 		}
@@ -1597,7 +1597,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 		 * done above for all cases requiring it to happen under page
 		 * table lock before mmu_notifier_invalidate_range_end()
 		 *
-		 * See Documentation/vm/mmu_notifier.txt
+		 * See Documentation/vm/mmu_notifier.rst
 		 */
 		page_remove_rmap(subpage, PageHuge(page));
 		put_page(page);
diff --git a/mm/util.c b/mm/util.c
index c125050..e857c80 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -609,7 +609,7 @@ EXPORT_SYMBOL_GPL(vm_memory_committed);
  * succeed and -ENOMEM implies there is not.
  *
  * We currently support three overcommit policies, which are set via the
- * vm.overcommit_memory sysctl.  See Documentation/vm/overcommit-accounting
+ * vm.overcommit_memory sysctl.  See Documentation/vm/overcommit-accounting.rst
  *
  * Strict overcommit modes added 2002 Feb 26 by Alan Cox.
  * Additional code 2002 Jul 20 by Robert Love.
-- 
2.7.4
