Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 970AE8E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:14:01 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id 20-v6so9263287ois.21
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 05:14:01 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id h12-v6si1555033otf.283.2018.09.14.05.13.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 05:14:00 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8EC5Opf006181
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:13:59 -0400
Received: from e06smtp01.uk.ibm.com (e06smtp01.uk.ibm.com [195.75.94.97])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mgb9y3vfg-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:13:59 -0400
Received: from localhost
	by e06smtp01.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 14 Sep 2018 13:13:55 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 28/30] memblock: replace BOOTMEM_ALLOC_* with MEMBLOCK variants
Date: Fri, 14 Sep 2018 15:10:43 +0300
In-Reply-To: <1536927045-23536-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1536927045-23536-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1536927045-23536-29-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Chris Zankel <chris@zankel.net>, "David S. Miller" <davem@davemloft.net>, Geert Uytterhoeven <geert@linux-m68k.org>, Greentime Hu <green.hu@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao <gxt@pku.edu.cn>, Ingo Molnar <mingo@redhat.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Jonas Bonn <jonas@southpole.se>, Jonathan Corbet <corbet@lwn.net>, Ley Foon Tan <lftan@altera.com>, Mark Salter <msalter@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Matt Turner <mattst88@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Michal Simek <monstr@monstr.eu>, Palmer Dabbelt <palmer@sifive.com>, Paul Burton <paul.burton@mips.com>, Richard Kuo <rkuo@codeaurora.org>, Richard Weinberger <richard@nod.at>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Serge Semin <fancer.lancer@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp, Mike Rapoport <rppt@linux.vnet.ibm.com>

Drop BOOTMEM_ALLOC_ACCESSIBLE and BOOTMEM_ALLOC_ANYWHERE in favor of
identical MEMBLOCK definitions.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 arch/ia64/mm/discontig.c       | 2 +-
 arch/powerpc/kernel/setup_64.c | 2 +-
 arch/sparc/kernel/smp_64.c     | 2 +-
 arch/x86/kernel/setup_percpu.c | 2 +-
 arch/x86/mm/kasan_init_64.c    | 4 ++--
 mm/hugetlb.c                   | 3 ++-
 mm/kasan/kasan_init.c          | 2 +-
 mm/memblock.c                  | 8 ++++----
 mm/page_ext.c                  | 2 +-
 mm/sparse-vmemmap.c            | 3 ++-
 mm/sparse.c                    | 5 +++--
 11 files changed, 19 insertions(+), 16 deletions(-)

diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index 918dda9..70609f8 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -453,7 +453,7 @@ static void __init *memory_less_node_alloc(int nid, unsigned long pernodesize)
 
 	ptr = memblock_alloc_try_nid(pernodesize, PERCPU_PAGE_SIZE,
 				     __pa(MAX_DMA_ADDRESS),
-				     BOOTMEM_ALLOC_ACCESSIBLE,
+				     MEMBLOCK_ALLOC_ACCESSIBLE,
 				     bestnode);
 
 	return ptr;
diff --git a/arch/powerpc/kernel/setup_64.c b/arch/powerpc/kernel/setup_64.c
index e564b27..b3e70cc 100644
--- a/arch/powerpc/kernel/setup_64.c
+++ b/arch/powerpc/kernel/setup_64.c
@@ -758,7 +758,7 @@ void __init emergency_stack_init(void)
 static void * __init pcpu_fc_alloc(unsigned int cpu, size_t size, size_t align)
 {
 	return memblock_alloc_try_nid(size, align, __pa(MAX_DMA_ADDRESS),
-				      BOOTMEM_ALLOC_ACCESSIBLE,
+				      MEMBLOCK_ALLOC_ACCESSIBLE,
 				      early_cpu_to_node(cpu));
 
 }
diff --git a/arch/sparc/kernel/smp_64.c b/arch/sparc/kernel/smp_64.c
index a087a6a..6cc80d0 100644
--- a/arch/sparc/kernel/smp_64.c
+++ b/arch/sparc/kernel/smp_64.c
@@ -1595,7 +1595,7 @@ static void * __init pcpu_alloc_bootmem(unsigned int cpu, size_t size,
 			 cpu, size, __pa(ptr));
 	} else {
 		ptr = memblock_alloc_try_nid(size, align, goal,
-					     BOOTMEM_ALLOC_ACCESSIBLE, node);
+					     MEMBLOCK_ALLOC_ACCESSIBLE, node);
 		pr_debug("per cpu data for cpu%d %lu bytes on node%d at "
 			 "%016lx\n", cpu, size, node, __pa(ptr));
 	}
diff --git a/arch/x86/kernel/setup_percpu.c b/arch/x86/kernel/setup_percpu.c
index a006f1b..483412f 100644
--- a/arch/x86/kernel/setup_percpu.c
+++ b/arch/x86/kernel/setup_percpu.c
@@ -114,7 +114,7 @@ static void * __init pcpu_alloc_bootmem(unsigned int cpu, unsigned long size,
 			 cpu, size, __pa(ptr));
 	} else {
 		ptr = memblock_alloc_try_nid_nopanic(size, align, goal,
-						     BOOTMEM_ALLOC_ACCESSIBLE,
+						     MEMBLOCK_ALLOC_ACCESSIBLE,
 						     node);
 
 		pr_debug("per cpu data for cpu%d %lu bytes on node%d at %016lx\n",
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index 77b857c..8f87499 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -29,10 +29,10 @@ static __init void *early_alloc(size_t size, int nid, bool panic)
 {
 	if (panic)
 		return memblock_alloc_try_nid(size, size,
-			__pa(MAX_DMA_ADDRESS), BOOTMEM_ALLOC_ACCESSIBLE, nid);
+			__pa(MAX_DMA_ADDRESS), MEMBLOCK_ALLOC_ACCESSIBLE, nid);
 	else
 		return memblock_alloc_try_nid_nopanic(size, size,
-			__pa(MAX_DMA_ADDRESS), BOOTMEM_ALLOC_ACCESSIBLE, nid);
+			__pa(MAX_DMA_ADDRESS), MEMBLOCK_ALLOC_ACCESSIBLE, nid);
 }
 
 static void __init kasan_populate_pmd(pmd_t *pmd, unsigned long addr,
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 3b63370..67629dc 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -16,6 +16,7 @@
 #include <linux/cpuset.h>
 #include <linux/mutex.h>
 #include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/sysfs.h>
 #include <linux/slab.h>
 #include <linux/mmdebug.h>
@@ -2102,7 +2103,7 @@ int __alloc_bootmem_huge_page(struct hstate *h)
 
 		addr = memblock_alloc_try_nid_raw(
 				huge_page_size(h), huge_page_size(h),
-				0, BOOTMEM_ALLOC_ACCESSIBLE, node);
+				0, MEMBLOCK_ALLOC_ACCESSIBLE, node);
 		if (addr) {
 			/*
 			 * Use the beginning of the huge page to store the
diff --git a/mm/kasan/kasan_init.c b/mm/kasan/kasan_init.c
index 24d734b..785a970 100644
--- a/mm/kasan/kasan_init.c
+++ b/mm/kasan/kasan_init.c
@@ -84,7 +84,7 @@ static inline bool kasan_zero_page_entry(pte_t pte)
 static __init void *early_alloc(size_t size, int node)
 {
 	return memblock_alloc_try_nid(size, size, __pa(MAX_DMA_ADDRESS),
-					BOOTMEM_ALLOC_ACCESSIBLE, node);
+					MEMBLOCK_ALLOC_ACCESSIBLE, node);
 }
 
 static void __ref zero_pte_populate(pmd_t *pmd, unsigned long addr,
diff --git a/mm/memblock.c b/mm/memblock.c
index 4591f38..86a4b80 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1393,7 +1393,7 @@ phys_addr_t __init memblock_phys_alloc_try_nid(phys_addr_t size, phys_addr_t ali
  * hold the requested memory.
  *
  * The allocation is performed from memory region limited by
- * memblock.current_limit if @max_addr == %BOOTMEM_ALLOC_ACCESSIBLE.
+ * memblock.current_limit if @max_addr == %MEMBLOCK_ALLOC_ACCESSIBLE.
  *
  * The memory block is aligned on %SMP_CACHE_BYTES if @align == 0.
  *
@@ -1480,7 +1480,7 @@ static void * __init memblock_alloc_internal(
  * @min_addr: the lower bound of the memory region from where the allocation
  *	  is preferred (phys address)
  * @max_addr: the upper bound of the memory region from where the allocation
- *	      is preferred (phys address), or %BOOTMEM_ALLOC_ACCESSIBLE to
+ *	      is preferred (phys address), or %MEMBLOCK_ALLOC_ACCESSIBLE to
  *	      allocate only from memory limited by memblock.current_limit value
  * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
  *
@@ -1518,7 +1518,7 @@ void * __init memblock_alloc_try_nid_raw(
  * @min_addr: the lower bound of the memory region from where the allocation
  *	  is preferred (phys address)
  * @max_addr: the upper bound of the memory region from where the allocation
- *	      is preferred (phys address), or %BOOTMEM_ALLOC_ACCESSIBLE to
+ *	      is preferred (phys address), or %MEMBLOCK_ALLOC_ACCESSIBLE to
  *	      allocate only from memory limited by memblock.current_limit value
  * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
  *
@@ -1553,7 +1553,7 @@ void * __init memblock_alloc_try_nid_nopanic(
  * @min_addr: the lower bound of the memory region from where the allocation
  *	  is preferred (phys address)
  * @max_addr: the upper bound of the memory region from where the allocation
- *	      is preferred (phys address), or %BOOTMEM_ALLOC_ACCESSIBLE to
+ *	      is preferred (phys address), or %MEMBLOCK_ALLOC_ACCESSIBLE to
  *	      allocate only from memory limited by memblock.current_limit value
  * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
  *
diff --git a/mm/page_ext.c b/mm/page_ext.c
index e77c0f0..5323c2a 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -163,7 +163,7 @@ static int __init alloc_node_page_ext(int nid)
 
 	base = memblock_alloc_try_nid_nopanic(
 			table_size, PAGE_SIZE, __pa(MAX_DMA_ADDRESS),
-			BOOTMEM_ALLOC_ACCESSIBLE, nid);
+			MEMBLOCK_ALLOC_ACCESSIBLE, nid);
 	if (!base)
 		return -ENOMEM;
 	NODE_DATA(nid)->node_page_ext = base;
diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index 91c2c3d..7408cab 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -21,6 +21,7 @@
 #include <linux/mm.h>
 #include <linux/mmzone.h>
 #include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/memremap.h>
 #include <linux/highmem.h>
 #include <linux/slab.h>
@@ -43,7 +44,7 @@ static void * __ref __earlyonly_bootmem_alloc(int node,
 				unsigned long goal)
 {
 	return memblock_alloc_try_nid_raw(size, align, goal,
-					       BOOTMEM_ALLOC_ACCESSIBLE, node);
+					       MEMBLOCK_ALLOC_ACCESSIBLE, node);
 }
 
 void * __meminit vmemmap_alloc_block(unsigned long size, int node)
diff --git a/mm/sparse.c b/mm/sparse.c
index 509828f..0dcc306 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -6,6 +6,7 @@
 #include <linux/slab.h>
 #include <linux/mmzone.h>
 #include <linux/bootmem.h>
+#include <linux/memblock.h>
 #include <linux/compiler.h>
 #include <linux/highmem.h>
 #include <linux/export.h>
@@ -393,7 +394,7 @@ struct page __init *sparse_mem_map_populate(unsigned long pnum, int nid,
 
 	map = memblock_alloc_try_nid(size,
 					  PAGE_SIZE, __pa(MAX_DMA_ADDRESS),
-					  BOOTMEM_ALLOC_ACCESSIBLE, nid);
+					  MEMBLOCK_ALLOC_ACCESSIBLE, nid);
 	return map;
 }
 #endif /* !CONFIG_SPARSEMEM_VMEMMAP */
@@ -407,7 +408,7 @@ static void __init sparse_buffer_init(unsigned long size, int nid)
 	sparsemap_buf =
 		memblock_alloc_try_nid_raw(size, PAGE_SIZE,
 						__pa(MAX_DMA_ADDRESS),
-						BOOTMEM_ALLOC_ACCESSIBLE, nid);
+						MEMBLOCK_ALLOC_ACCESSIBLE, nid);
 	sparsemap_buf_end = sparsemap_buf + size;
 }
 
-- 
2.7.4
