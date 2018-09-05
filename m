Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9B3DB6B73F3
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 12:00:06 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id t3-v6so9141274oif.20
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 09:00:06 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id a200-v6si1503752oib.18.2018.09.05.09.00.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 09:00:05 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w85FvI7F044759
	for <linux-mm@kvack.org>; Wed, 5 Sep 2018 12:00:04 -0400
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2magp9w2km-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 05 Sep 2018 12:00:01 -0400
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 5 Sep 2018 16:59:58 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [RFC PATCH 02/29] mm: remove CONFIG_NO_BOOTMEM
Date: Wed,  5 Sep 2018 18:59:17 +0300
In-Reply-To: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1536163184-26356-3-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Paul Burton <paul.burton@mips.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

All achitectures select NO_BOOTMEM which essentially becomes 'Y' for any
kernel configuration and therefore it can be removed.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 arch/alpha/Kconfig      |  1 -
 arch/arc/Kconfig        |  1 -
 arch/arm/Kconfig        |  1 -
 arch/arm64/Kconfig      |  1 -
 arch/c6x/Kconfig        |  1 -
 arch/h8300/Kconfig      |  1 -
 arch/hexagon/Kconfig    |  1 -
 arch/ia64/Kconfig       |  1 -
 arch/m68k/Kconfig       |  1 -
 arch/microblaze/Kconfig |  1 -
 arch/mips/Kconfig       |  1 -
 arch/nds32/Kconfig      |  1 -
 arch/nios2/Kconfig      |  1 -
 arch/openrisc/Kconfig   |  1 -
 arch/parisc/Kconfig     |  1 -
 arch/powerpc/Kconfig    |  1 -
 arch/riscv/Kconfig      |  1 -
 arch/s390/Kconfig       |  1 -
 arch/sh/Kconfig         |  1 -
 arch/sparc/Kconfig      |  1 -
 arch/um/Kconfig         |  1 -
 arch/unicore32/Kconfig  |  1 -
 arch/x86/Kconfig        |  3 ---
 arch/xtensa/Kconfig     |  1 -
 include/linux/bootmem.h | 36 ++----------------------------------
 include/linux/mmzone.h  |  5 +----
 mm/Kconfig              |  3 ---
 mm/Makefile             |  7 +------
 mm/memblock.c           |  2 --
 29 files changed, 4 insertions(+), 75 deletions(-)

diff --git a/arch/alpha/Kconfig b/arch/alpha/Kconfig
index 620b0a7..04de6be 100644
--- a/arch/alpha/Kconfig
+++ b/arch/alpha/Kconfig
@@ -32,7 +32,6 @@ config ALPHA
 	select OLD_SIGSUSPEND
 	select CPU_NO_EFFICIENT_FFS if !ALPHA_EV67
 	select HAVE_MEMBLOCK
-	select NO_BOOTMEM
 	help
 	  The Alpha is a 64-bit general-purpose processor designed and
 	  marketed by the Digital Equipment Corporation of blessed memory,
diff --git a/arch/arc/Kconfig b/arch/arc/Kconfig
index b4441b0..04ebead 100644
--- a/arch/arc/Kconfig
+++ b/arch/arc/Kconfig
@@ -44,7 +44,6 @@ config ARC
 	select HANDLE_DOMAIN_IRQ
 	select IRQ_DOMAIN
 	select MODULES_USE_ELF_RELA
-	select NO_BOOTMEM
 	select OF
 	select OF_EARLY_FLATTREE
 	select OF_RESERVED_MEM
diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index ed74be4..61ea3dd 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -100,7 +100,6 @@ config ARM
 	select IRQ_FORCED_THREADING
 	select MODULES_USE_ELF_REL
 	select NEED_DMA_MAP_STATE
-	select NO_BOOTMEM
 	select OF_EARLY_FLATTREE if OF
 	select OF_RESERVED_MEM if OF
 	select OLD_SIGACTION
diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index c05ab9e..0065653 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -154,7 +154,6 @@ config ARM64
 	select MULTI_IRQ_HANDLER
 	select NEED_DMA_MAP_STATE
 	select NEED_SG_DMA_LENGTH
-	select NO_BOOTMEM
 	select OF
 	select OF_EARLY_FLATTREE
 	select OF_RESERVED_MEM
diff --git a/arch/c6x/Kconfig b/arch/c6x/Kconfig
index 85ed568..a641b0b 100644
--- a/arch/c6x/Kconfig
+++ b/arch/c6x/Kconfig
@@ -14,7 +14,6 @@ config C6X
 	select GENERIC_IRQ_SHOW
 	select HAVE_ARCH_TRACEHOOK
 	select HAVE_MEMBLOCK
-	select NO_BOOTMEM
 	select SPARSE_IRQ
 	select IRQ_DOMAIN
 	select OF
diff --git a/arch/h8300/Kconfig b/arch/h8300/Kconfig
index 0b334b6..5e89d40 100644
--- a/arch/h8300/Kconfig
+++ b/arch/h8300/Kconfig
@@ -16,7 +16,6 @@ config H8300
 	select OF_IRQ
 	select OF_EARLY_FLATTREE
 	select HAVE_MEMBLOCK
-	select NO_BOOTMEM
 	select TIMER_OF
 	select H8300_TMR8
 	select HAVE_KERNEL_GZIP
diff --git a/arch/hexagon/Kconfig b/arch/hexagon/Kconfig
index f793499..fb7e0ba 100644
--- a/arch/hexagon/Kconfig
+++ b/arch/hexagon/Kconfig
@@ -31,7 +31,6 @@ config HEXAGON
 	select GENERIC_CPU_DEVICES
 	select HAVE_MEMBLOCK
 	select ARCH_DISCARD_MEMBLOCK
-	select NO_BOOTMEM
 	---help---
 	  Qualcomm Hexagon is a processor architecture designed for high
 	  performance and low power across a wide variety of applications.
diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 8b4a0c17..2bf4ef7 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -28,7 +28,6 @@ config IA64
 	select HAVE_ARCH_TRACEHOOK
 	select HAVE_MEMBLOCK
 	select HAVE_MEMBLOCK_NODE_MAP
-	select NO_BOOTMEM
 	select HAVE_VIRT_CPU_ACCOUNTING
 	select ARCH_HAS_DMA_MARK_CLEAN
 	select ARCH_HAS_SG_CHAIN
diff --git a/arch/m68k/Kconfig b/arch/m68k/Kconfig
index 0705537..8c7111d 100644
--- a/arch/m68k/Kconfig
+++ b/arch/m68k/Kconfig
@@ -29,7 +29,6 @@ config M68K
 	select DMA_NONCOHERENT_OPS if HAS_DMA
 	select HAVE_MEMBLOCK
 	select ARCH_DISCARD_MEMBLOCK
-	select NO_BOOTMEM
 
 config CPU_BIG_ENDIAN
 	def_bool y
diff --git a/arch/microblaze/Kconfig b/arch/microblaze/Kconfig
index ace5c5b..56379b9 100644
--- a/arch/microblaze/Kconfig
+++ b/arch/microblaze/Kconfig
@@ -28,7 +28,6 @@ config MICROBLAZE
 	select HAVE_FTRACE_MCOUNT_RECORD
 	select HAVE_FUNCTION_GRAPH_TRACER
 	select HAVE_FUNCTION_TRACER
-	select NO_BOOTMEM
 	select HAVE_MEMBLOCK
 	select HAVE_MEMBLOCK_NODE_MAP
 	select HAVE_OPROFILE
diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
index f744d25..1a119fd 100644
--- a/arch/mips/Kconfig
+++ b/arch/mips/Kconfig
@@ -78,7 +78,6 @@ config MIPS
 	select RTC_LIB if !MACH_LOONGSON64
 	select SYSCTL_EXCEPTION_TRACE
 	select VIRT_TO_BUS
-	select NO_BOOTMEM
 
 menu "Machine selection"
 
diff --git a/arch/nds32/Kconfig b/arch/nds32/Kconfig
index 7068f34..06b1259 100644
--- a/arch/nds32/Kconfig
+++ b/arch/nds32/Kconfig
@@ -36,7 +36,6 @@ config NDS32
 	select MODULES_USE_ELF_RELA
 	select OF
 	select OF_EARLY_FLATTREE
-	select NO_BOOTMEM
 	select NO_IOPORT_MAP
 	select RTC_LIB
 	select THREAD_INFO_IN_TASK
diff --git a/arch/nios2/Kconfig b/arch/nios2/Kconfig
index 5ddf272..ebfae50 100644
--- a/arch/nios2/Kconfig
+++ b/arch/nios2/Kconfig
@@ -25,7 +25,6 @@ config NIOS2
 	select CPU_NO_EFFICIENT_FFS
 	select HAVE_MEMBLOCK
 	select ARCH_DISCARD_MEMBLOCK
-	select NO_BOOTMEM
 
 config GENERIC_CSUM
 	def_bool y
diff --git a/arch/openrisc/Kconfig b/arch/openrisc/Kconfig
index e0081e7..25c6c2e 100644
--- a/arch/openrisc/Kconfig
+++ b/arch/openrisc/Kconfig
@@ -32,7 +32,6 @@ config OPENRISC
 	select HAVE_DEBUG_STACKOVERFLOW
 	select OR1K_PIC
 	select CPU_NO_EFFICIENT_FFS if !OPENRISC_HAVE_INST_FF1
-	select NO_BOOTMEM
 	select ARCH_USE_QUEUED_SPINLOCKS
 	select ARCH_USE_QUEUED_RWLOCKS
 	select OMPIC if SMP
diff --git a/arch/parisc/Kconfig b/arch/parisc/Kconfig
index 8e6d83f..1d6332c 100644
--- a/arch/parisc/Kconfig
+++ b/arch/parisc/Kconfig
@@ -16,7 +16,6 @@ config PARISC
 	select RTC_DRV_GENERIC
 	select INIT_ALL_POSSIBLE
 	select HAVE_MEMBLOCK
-	select NO_BOOTMEM
 	select BUG
 	select BUILDTIME_EXTABLE_SORT
 	select HAVE_PERF_EVENTS
diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index a806692..304cdce 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -228,7 +228,6 @@ config PPC
 	select MODULES_USE_ELF_RELA
 	select NEED_DMA_MAP_STATE		if PPC64 || NOT_COHERENT_CACHE
 	select NEED_SG_DMA_LENGTH
-	select NO_BOOTMEM
 	select OF
 	select OF_EARLY_FLATTREE
 	select OF_RESERVED_MEM
diff --git a/arch/riscv/Kconfig b/arch/riscv/Kconfig
index a344980..63301c8 100644
--- a/arch/riscv/Kconfig
+++ b/arch/riscv/Kconfig
@@ -34,7 +34,6 @@ config RISCV
 	select HAVE_GENERIC_DMA_COHERENT
 	select HAVE_PERF_EVENTS
 	select IRQ_DOMAIN
-	select NO_BOOTMEM
 	select RISCV_ISA_A if SMP
 	select SPARSE_IRQ
 	select SYSCTL_EXCEPTION_TRACE
diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index 9a9c7a6..b388e05 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -166,7 +166,6 @@ config S390
 	select HAVE_SYSCALL_TRACEPOINTS
 	select HAVE_VIRT_CPU_ACCOUNTING
 	select MODULES_USE_ELF_RELA
-	select NO_BOOTMEM
 	select OLD_SIGACTION
 	select OLD_SIGSUSPEND3
 	select SPARSE_IRQ
diff --git a/arch/sh/Kconfig b/arch/sh/Kconfig
index 1fb7b6d..e254226 100644
--- a/arch/sh/Kconfig
+++ b/arch/sh/Kconfig
@@ -10,7 +10,6 @@ config SUPERH
 	select HAVE_IDE if HAS_IOPORT_MAP
 	select HAVE_MEMBLOCK
 	select HAVE_MEMBLOCK_NODE_MAP
-	select NO_BOOTMEM
 	select ARCH_DISCARD_MEMBLOCK
 	select HAVE_OPROFILE
 	select HAVE_GENERIC_DMA_COHERENT
diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index e6f2a38..5e8aaee 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -46,7 +46,6 @@ config SPARC
 	select NEED_DMA_MAP_STATE
 	select NEED_SG_DMA_LENGTH
 	select HAVE_MEMBLOCK
-	select NO_BOOTMEM
 
 config SPARC32
 	def_bool !64BIT
diff --git a/arch/um/Kconfig b/arch/um/Kconfig
index 10c15b8..ce3d562 100644
--- a/arch/um/Kconfig
+++ b/arch/um/Kconfig
@@ -13,7 +13,6 @@ config UML
 	select HAVE_FUTEX_CMPXCHG if FUTEX
 	select HAVE_DEBUG_KMEMLEAK
 	select HAVE_MEMBLOCK
-	select NO_BOOTMEM
 	select GENERIC_IRQ_SHOW
 	select GENERIC_CPU_DEVICES
 	select GENERIC_CLOCKEVENTS
diff --git a/arch/unicore32/Kconfig b/arch/unicore32/Kconfig
index 6f38f7f..60eae74 100644
--- a/arch/unicore32/Kconfig
+++ b/arch/unicore32/Kconfig
@@ -5,7 +5,6 @@ config UNICORE32
 	select ARCH_MIGHT_HAVE_PC_PARPORT
 	select ARCH_MIGHT_HAVE_PC_SERIO
 	select HAVE_MEMBLOCK
-	select NO_BOOTMEM
 	select HAVE_GENERIC_DMA_COHERENT
 	select HAVE_KERNEL_GZIP
 	select HAVE_KERNEL_BZIP2
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index fc5439d..5a861bd 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -831,9 +831,6 @@ config JAILHOUSE_GUEST
 
 endif #HYPERVISOR_GUEST
 
-config NO_BOOTMEM
-	def_bool y
-
 source "arch/x86/Kconfig.cpu"
 
 config HPET_TIMER
diff --git a/arch/xtensa/Kconfig b/arch/xtensa/Kconfig
index 04d038f..e4f7d12 100644
--- a/arch/xtensa/Kconfig
+++ b/arch/xtensa/Kconfig
@@ -33,7 +33,6 @@ config XTENSA
 	select HAVE_STACKPROTECTOR
 	select IRQ_DOMAIN
 	select MODULES_USE_ELF_RELA
-	select NO_BOOTMEM
 	select PERF_USE_VMALLOC
 	select VIRT_TO_BUS
 	help
diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index 4251519..1f005b5 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -26,34 +26,6 @@ extern unsigned long max_pfn;
  */
 extern unsigned long long max_possible_pfn;
 
-#ifndef CONFIG_NO_BOOTMEM
-/**
- * struct bootmem_data - per-node information used by the bootmem allocator
- * @node_min_pfn: the starting physical address of the node's memory
- * @node_low_pfn: the end physical address of the directly addressable memory
- * @node_bootmem_map: is a bitmap pointer - the bits represent all physical
- *		      memory pages (including holes) on the node.
- * @last_end_off: the offset within the page of the end of the last allocation;
- *                if 0, the page used is full
- * @hint_idx: the PFN of the page used with the last allocation;
- *            together with using this with the @last_end_offset field,
- *            a test can be made to see if allocations can be merged
- *            with the page used for the last allocation rather than
- *            using up a full new page.
- * @list: list entry in the linked list ordered by the memory addresses
- */
-typedef struct bootmem_data {
-	unsigned long node_min_pfn;
-	unsigned long node_low_pfn;
-	void *node_bootmem_map;
-	unsigned long last_end_off;
-	unsigned long hint_idx;
-	struct list_head list;
-} bootmem_data_t;
-
-extern bootmem_data_t bootmem_node_data[];
-#endif
-
 extern unsigned long bootmem_bootmap_pages(unsigned long);
 
 extern unsigned long init_bootmem_node(pg_data_t *pgdat,
@@ -125,12 +97,8 @@ extern void *__alloc_bootmem_low_node(pg_data_t *pgdat,
 				      unsigned long align,
 				      unsigned long goal) __malloc;
 
-#ifdef CONFIG_NO_BOOTMEM
 /* We are using top down, so it is safe to use 0 here */
 #define BOOTMEM_LOW_LIMIT 0
-#else
-#define BOOTMEM_LOW_LIMIT __pa(MAX_DMA_ADDRESS)
-#endif
 
 #ifndef ARCH_LOW_ADDRESS_LIMIT
 #define ARCH_LOW_ADDRESS_LIMIT  0xffffffffUL
@@ -165,7 +133,7 @@ extern void *__alloc_bootmem_low_node(pg_data_t *pgdat,
 	__alloc_bootmem_low_node(pgdat, x, PAGE_SIZE, 0)
 
 
-#if defined(CONFIG_HAVE_MEMBLOCK) && defined(CONFIG_NO_BOOTMEM)
+#if defined(CONFIG_HAVE_MEMBLOCK)
 
 /* FIXME: use MEMBLOCK_ALLOC_* variants here */
 #define BOOTMEM_ALLOC_ACCESSIBLE	0
@@ -373,7 +341,7 @@ static inline void __init memblock_free_late(
 {
 	free_bootmem_late(base, size);
 }
-#endif /* defined(CONFIG_HAVE_MEMBLOCK) && defined(CONFIG_NO_BOOTMEM) */
+#endif /* defined(CONFIG_HAVE_MEMBLOCK) */
 
 extern void *alloc_large_system_hash(const char *tablename,
 				     unsigned long bucketsize,
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index f09d27c..f09b437 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -631,9 +631,6 @@ typedef struct pglist_data {
 	struct page_ext *node_page_ext;
 #endif
 #endif
-#ifndef CONFIG_NO_BOOTMEM
-	struct bootmem_data *bdata;
-#endif
 #if defined(CONFIG_MEMORY_HOTPLUG) || defined(CONFIG_DEFERRED_STRUCT_PAGE_INIT)
 	/*
 	 * Must be held any time you expect node_start_pfn, node_present_pages
@@ -877,7 +874,7 @@ static inline int is_highmem_idx(enum zone_type idx)
 }
 
 /**
- * is_highmem - helper function to quickly check if a struct zone is a 
+ * is_highmem - helper function to quickly check if a struct zone is a
  *              highmem zone or not.  This is an attempt to keep references
  *              to ZONE_{DMA/NORMAL/HIGHMEM/etc} in general code to a minimum.
  * @zone - pointer to struct zone variable
diff --git a/mm/Kconfig b/mm/Kconfig
index 7bf074b..16ceea0 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -145,9 +145,6 @@ config HAVE_GENERIC_GUP
 config ARCH_DISCARD_MEMBLOCK
 	bool
 
-config NO_BOOTMEM
-	bool
-
 config MEMORY_ISOLATION
 	bool
 
diff --git a/mm/Makefile b/mm/Makefile
index 26ef77a..c4da6de 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -42,12 +42,7 @@ obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
 			   debug.o $(mmu-y)
 
 obj-y += init-mm.o
-
-ifdef CONFIG_NO_BOOTMEM
-	obj-y		+= nobootmem.o
-else
-	obj-y		+= bootmem.o
-endif
+obj-y += nobootmem.o
 
 ifdef CONFIG_MMU
 	obj-$(CONFIG_ADVISE_SYSCALLS)	+= madvise.o
diff --git a/mm/memblock.c b/mm/memblock.c
index b9f593da..2a5940c 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1393,7 +1393,6 @@ phys_addr_t __init memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, i
 	return memblock_alloc_base(size, align, MEMBLOCK_ALLOC_ACCESSIBLE);
 }
 
-#if defined(CONFIG_NO_BOOTMEM)
 /**
  * memblock_virt_alloc_internal - allocate boot memory block
  * @size: size of memory block to be allocated in bytes
@@ -1600,7 +1599,6 @@ void * __init memblock_virt_alloc_try_nid(
 	      __func__, (u64)size, (u64)align, nid, &min_addr, &max_addr);
 	return NULL;
 }
-#endif
 
 /**
  * __memblock_free_early - free boot memory block
-- 
2.7.4
