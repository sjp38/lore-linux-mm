Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0FA096B73FA
	for <linux-mm@kvack.org>; Wed,  5 Sep 2018 12:00:16 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id m197-v6so8955522oig.18
        for <linux-mm@kvack.org>; Wed, 05 Sep 2018 09:00:16 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t131-v6si1587462oig.46.2018.09.05.09.00.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Sep 2018 09:00:14 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w85FtVwm022465
	for <linux-mm@kvack.org>; Wed, 5 Sep 2018 12:00:13 -0400
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2maj548jbh-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 05 Sep 2018 12:00:04 -0400
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Wed, 5 Sep 2018 17:00:02 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [RFC PATCH 03/29] mm: remove CONFIG_HAVE_MEMBLOCK
Date: Wed,  5 Sep 2018 18:59:18 +0300
In-Reply-To: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1536163184-26356-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1536163184-26356-4-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Ingo Molnar <mingo@redhat.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Paul Burton <paul.burton@mips.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, linux-ia64@vger.kernel.org, linux-mips@linux-mips.org, linuxppc-dev@lists.ozlabs.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>

All architecures use memblock for early memory management. There is no need
for the CONFIG_HAVE_MEMBLOCK configuration option.

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 arch/alpha/Kconfig                  |   1 -
 arch/arc/Kconfig                    |   1 -
 arch/arm/Kconfig                    |   1 -
 arch/arm64/Kconfig                  |   1 -
 arch/c6x/Kconfig                    |   1 -
 arch/h8300/Kconfig                  |   1 -
 arch/hexagon/Kconfig                |   1 -
 arch/ia64/Kconfig                   |   1 -
 arch/m68k/Kconfig                   |   1 -
 arch/microblaze/Kconfig             |   1 -
 arch/mips/Kconfig                   |   1 -
 arch/nds32/Kconfig                  |   1 -
 arch/nios2/Kconfig                  |   1 -
 arch/openrisc/Kconfig               |   1 -
 arch/parisc/Kconfig                 |   1 -
 arch/powerpc/Kconfig                |   1 -
 arch/riscv/Kconfig                  |   1 -
 arch/s390/Kconfig                   |   1 -
 arch/sh/Kconfig                     |   1 -
 arch/sparc/Kconfig                  |   1 -
 arch/um/Kconfig                     |   1 -
 arch/unicore32/Kconfig              |   1 -
 arch/x86/Kconfig                    |   1 -
 arch/xtensa/Kconfig                 |   1 -
 drivers/of/fdt.c                    |   2 -
 drivers/of/of_reserved_mem.c        |  13 +----
 drivers/staging/android/ion/Kconfig |   2 +-
 fs/pstore/Kconfig                   |   1 -
 include/linux/bootmem.h             | 112 ------------------------------------
 include/linux/memblock.h            |   2 -
 include/linux/mm.h                  |   2 +-
 lib/Kconfig.debug                   |   3 +-
 mm/Kconfig                          |   5 +-
 mm/Makefile                         |   2 +-
 mm/nobootmem.c                      |   4 --
 mm/page_alloc.c                     |   4 +-
 36 files changed, 8 insertions(+), 168 deletions(-)

diff --git a/arch/alpha/Kconfig b/arch/alpha/Kconfig
index 04de6be..5b4f883 100644
--- a/arch/alpha/Kconfig
+++ b/arch/alpha/Kconfig
@@ -31,7 +31,6 @@ config ALPHA
 	select ODD_RT_SIGACTION
 	select OLD_SIGSUSPEND
 	select CPU_NO_EFFICIENT_FFS if !ALPHA_EV67
-	select HAVE_MEMBLOCK
 	help
 	  The Alpha is a 64-bit general-purpose processor designed and
 	  marketed by the Digital Equipment Corporation of blessed memory,
diff --git a/arch/arc/Kconfig b/arch/arc/Kconfig
index 04ebead..5260440 100644
--- a/arch/arc/Kconfig
+++ b/arch/arc/Kconfig
@@ -37,7 +37,6 @@ config ARC
 	select HAVE_KERNEL_LZMA
 	select HAVE_KPROBES
 	select HAVE_KRETPROBES
-	select HAVE_MEMBLOCK
 	select HAVE_MOD_ARCH_SPECIFIC
 	select HAVE_OPROFILE
 	select HAVE_PERF_EVENTS
diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 61ea3dd..07468e6 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -82,7 +82,6 @@ config ARM
 	select HAVE_KERNEL_XZ
 	select HAVE_KPROBES if !XIP_KERNEL && !CPU_ENDIAN_BE32 && !CPU_V7M
 	select HAVE_KRETPROBES if (HAVE_KPROBES)
-	select HAVE_MEMBLOCK
 	select HAVE_MOD_ARCH_SPECIFIC
 	select HAVE_NMI
 	select HAVE_OPROFILE if (HAVE_PERF_EVENTS)
diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 0065653..7d7d813 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -133,7 +133,6 @@ config ARM64
 	select HAVE_GENERIC_DMA_COHERENT
 	select HAVE_HW_BREAKPOINT if PERF_EVENTS
 	select HAVE_IRQ_TIME_ACCOUNTING
-	select HAVE_MEMBLOCK
 	select HAVE_MEMBLOCK_NODE_MAP if NUMA
 	select HAVE_NMI
 	select HAVE_PATA_PLATFORM
diff --git a/arch/c6x/Kconfig b/arch/c6x/Kconfig
index a641b0b..833fdb0 100644
--- a/arch/c6x/Kconfig
+++ b/arch/c6x/Kconfig
@@ -13,7 +13,6 @@ config C6X
 	select GENERIC_ATOMIC64
 	select GENERIC_IRQ_SHOW
 	select HAVE_ARCH_TRACEHOOK
-	select HAVE_MEMBLOCK
 	select SPARSE_IRQ
 	select IRQ_DOMAIN
 	select OF
diff --git a/arch/h8300/Kconfig b/arch/h8300/Kconfig
index 5e89d40..d19c6b16 100644
--- a/arch/h8300/Kconfig
+++ b/arch/h8300/Kconfig
@@ -15,7 +15,6 @@ config H8300
 	select OF
 	select OF_IRQ
 	select OF_EARLY_FLATTREE
-	select HAVE_MEMBLOCK
 	select TIMER_OF
 	select H8300_TMR8
 	select HAVE_KERNEL_GZIP
diff --git a/arch/hexagon/Kconfig b/arch/hexagon/Kconfig
index fb7e0ba..d86e134 100644
--- a/arch/hexagon/Kconfig
+++ b/arch/hexagon/Kconfig
@@ -29,7 +29,6 @@ config HEXAGON
 	select GENERIC_CLOCKEVENTS_BROADCAST
 	select MODULES_USE_ELF_RELA
 	select GENERIC_CPU_DEVICES
-	select HAVE_MEMBLOCK
 	select ARCH_DISCARD_MEMBLOCK
 	---help---
 	  Qualcomm Hexagon is a processor architecture designed for high
diff --git a/arch/ia64/Kconfig b/arch/ia64/Kconfig
index 2bf4ef7..36773de 100644
--- a/arch/ia64/Kconfig
+++ b/arch/ia64/Kconfig
@@ -26,7 +26,6 @@ config IA64
 	select HAVE_FUNCTION_TRACER
 	select TTY
 	select HAVE_ARCH_TRACEHOOK
-	select HAVE_MEMBLOCK
 	select HAVE_MEMBLOCK_NODE_MAP
 	select HAVE_VIRT_CPU_ACCOUNTING
 	select ARCH_HAS_DMA_MARK_CLEAN
diff --git a/arch/m68k/Kconfig b/arch/m68k/Kconfig
index 8c7111d..e88588b 100644
--- a/arch/m68k/Kconfig
+++ b/arch/m68k/Kconfig
@@ -27,7 +27,6 @@ config M68K
 	select OLD_SIGSUSPEND3
 	select OLD_SIGACTION
 	select DMA_NONCOHERENT_OPS if HAS_DMA
-	select HAVE_MEMBLOCK
 	select ARCH_DISCARD_MEMBLOCK
 
 config CPU_BIG_ENDIAN
diff --git a/arch/microblaze/Kconfig b/arch/microblaze/Kconfig
index 56379b9..c77eaef 100644
--- a/arch/microblaze/Kconfig
+++ b/arch/microblaze/Kconfig
@@ -28,7 +28,6 @@ config MICROBLAZE
 	select HAVE_FTRACE_MCOUNT_RECORD
 	select HAVE_FUNCTION_GRAPH_TRACER
 	select HAVE_FUNCTION_TRACER
-	select HAVE_MEMBLOCK
 	select HAVE_MEMBLOCK_NODE_MAP
 	select HAVE_OPROFILE
 	select IRQ_DOMAIN
diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
index 1a119fd..be5786b 100644
--- a/arch/mips/Kconfig
+++ b/arch/mips/Kconfig
@@ -60,7 +60,6 @@ config MIPS
 	select HAVE_IRQ_TIME_ACCOUNTING
 	select HAVE_KPROBES
 	select HAVE_KRETPROBES
-	select HAVE_MEMBLOCK
 	select HAVE_MEMBLOCK_NODE_MAP
 	select HAVE_MOD_ARCH_SPECIFIC
 	select HAVE_NMI
diff --git a/arch/nds32/Kconfig b/arch/nds32/Kconfig
index 06b1259..605d148 100644
--- a/arch/nds32/Kconfig
+++ b/arch/nds32/Kconfig
@@ -29,7 +29,6 @@ config NDS32
 	select HANDLE_DOMAIN_IRQ
 	select HAVE_ARCH_TRACEHOOK
 	select HAVE_DEBUG_KMEMLEAK
-	select HAVE_MEMBLOCK
 	select HAVE_REGS_AND_STACK_ACCESS_API
 	select IRQ_DOMAIN
 	select LOCKDEP_SUPPORT
diff --git a/arch/nios2/Kconfig b/arch/nios2/Kconfig
index ebfae50..6f43bc4 100644
--- a/arch/nios2/Kconfig
+++ b/arch/nios2/Kconfig
@@ -23,7 +23,6 @@ config NIOS2
 	select SPARSE_IRQ
 	select USB_ARCH_HAS_HCD if USB_SUPPORT
 	select CPU_NO_EFFICIENT_FFS
-	select HAVE_MEMBLOCK
 	select ARCH_DISCARD_MEMBLOCK
 
 config GENERIC_CSUM
diff --git a/arch/openrisc/Kconfig b/arch/openrisc/Kconfig
index 25c6c2e..2ba6c6d 100644
--- a/arch/openrisc/Kconfig
+++ b/arch/openrisc/Kconfig
@@ -12,7 +12,6 @@ config OPENRISC
 	select OF_EARLY_FLATTREE
 	select IRQ_DOMAIN
 	select HANDLE_DOMAIN_IRQ
-	select HAVE_MEMBLOCK
 	select GPIOLIB
         select HAVE_ARCH_TRACEHOOK
 	select SPARSE_IRQ
diff --git a/arch/parisc/Kconfig b/arch/parisc/Kconfig
index 1d6332c..c8a6fda 100644
--- a/arch/parisc/Kconfig
+++ b/arch/parisc/Kconfig
@@ -15,7 +15,6 @@ config PARISC
 	select RTC_CLASS
 	select RTC_DRV_GENERIC
 	select INIT_ALL_POSSIBLE
-	select HAVE_MEMBLOCK
 	select BUG
 	select BUILDTIME_EXTABLE_SORT
 	select HAVE_PERF_EVENTS
diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 304cdce..47c16ae 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -203,7 +203,6 @@ config PPC
 	select HAVE_KRETPROBES
 	select HAVE_LD_DEAD_CODE_DATA_ELIMINATION
 	select HAVE_LIVEPATCH			if HAVE_DYNAMIC_FTRACE_WITH_REGS
-	select HAVE_MEMBLOCK
 	select HAVE_MEMBLOCK_NODE_MAP
 	select HAVE_MOD_ARCH_SPECIFIC
 	select HAVE_NMI				if PERF_EVENTS || (PPC64 && PPC_BOOK3S)
diff --git a/arch/riscv/Kconfig b/arch/riscv/Kconfig
index 63301c8..b92ee2f 100644
--- a/arch/riscv/Kconfig
+++ b/arch/riscv/Kconfig
@@ -28,7 +28,6 @@ config RISCV
 	select GENERIC_STRNLEN_USER
 	select GENERIC_SMP_IDLE_THREAD
 	select GENERIC_ATOMIC64 if !64BIT || !RISCV_ISA_A
-	select HAVE_MEMBLOCK
 	select HAVE_MEMBLOCK_NODE_MAP
 	select HAVE_DMA_CONTIGUOUS
 	select HAVE_GENERIC_DMA_COHERENT
diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index b388e05..2ccad0b 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -154,7 +154,6 @@ config S390
 	select HAVE_LIVEPATCH
 	select HAVE_PERF_REGS
 	select HAVE_PERF_USER_STACK_DUMP
-	select HAVE_MEMBLOCK
 	select HAVE_MEMBLOCK_NODE_MAP
 	select HAVE_MEMBLOCK_PHYS_MAP
 	select HAVE_MOD_ARCH_SPECIFIC
diff --git a/arch/sh/Kconfig b/arch/sh/Kconfig
index e254226..f89a172 100644
--- a/arch/sh/Kconfig
+++ b/arch/sh/Kconfig
@@ -8,7 +8,6 @@ config SUPERH
 	select HAVE_PATA_PLATFORM
 	select CLKDEV_LOOKUP
 	select HAVE_IDE if HAS_IOPORT_MAP
-	select HAVE_MEMBLOCK
 	select HAVE_MEMBLOCK_NODE_MAP
 	select ARCH_DISCARD_MEMBLOCK
 	select HAVE_OPROFILE
diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index 5e8aaee..3b2a2f3 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -45,7 +45,6 @@ config SPARC
 	select LOCKDEP_SMALL if LOCKDEP
 	select NEED_DMA_MAP_STATE
 	select NEED_SG_DMA_LENGTH
-	select HAVE_MEMBLOCK
 
 config SPARC32
 	def_bool !64BIT
diff --git a/arch/um/Kconfig b/arch/um/Kconfig
index ce3d562..6b99389 100644
--- a/arch/um/Kconfig
+++ b/arch/um/Kconfig
@@ -12,7 +12,6 @@ config UML
 	select HAVE_UID16
 	select HAVE_FUTEX_CMPXCHG if FUTEX
 	select HAVE_DEBUG_KMEMLEAK
-	select HAVE_MEMBLOCK
 	select GENERIC_IRQ_SHOW
 	select GENERIC_CPU_DEVICES
 	select GENERIC_CLOCKEVENTS
diff --git a/arch/unicore32/Kconfig b/arch/unicore32/Kconfig
index 60eae74..8726acd 100644
--- a/arch/unicore32/Kconfig
+++ b/arch/unicore32/Kconfig
@@ -4,7 +4,6 @@ config UNICORE32
 	select ARCH_HAS_DEVMEM_IS_ALLOWED
 	select ARCH_MIGHT_HAVE_PC_PARPORT
 	select ARCH_MIGHT_HAVE_PC_SERIO
-	select HAVE_MEMBLOCK
 	select HAVE_GENERIC_DMA_COHERENT
 	select HAVE_KERNEL_GZIP
 	select HAVE_KERNEL_BZIP2
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 5a861bd..875bef8e 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -167,7 +167,6 @@ config X86
 	select HAVE_KRETPROBES
 	select HAVE_KVM
 	select HAVE_LIVEPATCH			if X86_64
-	select HAVE_MEMBLOCK
 	select HAVE_MEMBLOCK_NODE_MAP
 	select HAVE_MIXED_BREAKPOINTS_REGS
 	select HAVE_MOD_ARCH_SPECIFIC
diff --git a/arch/xtensa/Kconfig b/arch/xtensa/Kconfig
index e4f7d12..2f7c086 100644
--- a/arch/xtensa/Kconfig
+++ b/arch/xtensa/Kconfig
@@ -27,7 +27,6 @@ config XTENSA
 	select HAVE_FUTEX_CMPXCHG if !MMU
 	select HAVE_HW_BREAKPOINT if PERF_EVENTS
 	select HAVE_IRQ_TIME_ACCOUNTING
-	select HAVE_MEMBLOCK
 	select HAVE_OPROFILE
 	select HAVE_PERF_EVENTS
 	select HAVE_STACKPROTECTOR
diff --git a/drivers/of/fdt.c b/drivers/of/fdt.c
index 76c83c1..bd841bb 100644
--- a/drivers/of/fdt.c
+++ b/drivers/of/fdt.c
@@ -1115,13 +1115,11 @@ int __init early_init_dt_scan_chosen(unsigned long node, const char *uname,
 	return 1;
 }
 
-#ifdef CONFIG_HAVE_MEMBLOCK
 #ifndef MIN_MEMBLOCK_ADDR
 #define MIN_MEMBLOCK_ADDR	__pa(PAGE_OFFSET)
 #endif
 #ifndef MAX_MEMBLOCK_ADDR
 #define MAX_MEMBLOCK_ADDR	((phys_addr_t)~0)
-#endif
 
 void __init __weak early_init_dt_add_memory_arch(u64 base, u64 size)
 {
diff --git a/drivers/of/of_reserved_mem.c b/drivers/of/of_reserved_mem.c
index 895c83e..d6255c2 100644
--- a/drivers/of/of_reserved_mem.c
+++ b/drivers/of/of_reserved_mem.c
@@ -20,13 +20,12 @@
 #include <linux/of_reserved_mem.h>
 #include <linux/sort.h>
 #include <linux/slab.h>
+#include <linux/memblock.h>
 
 #define MAX_RESERVED_REGIONS	32
 static struct reserved_mem reserved_mem[MAX_RESERVED_REGIONS];
 static int reserved_mem_count;
 
-#if defined(CONFIG_HAVE_MEMBLOCK)
-#include <linux/memblock.h>
 int __init __weak early_init_dt_alloc_reserved_memory_arch(phys_addr_t size,
 	phys_addr_t align, phys_addr_t start, phys_addr_t end, bool nomap,
 	phys_addr_t *res_base)
@@ -54,16 +53,6 @@ int __init __weak early_init_dt_alloc_reserved_memory_arch(phys_addr_t size,
 		return memblock_remove(base, size);
 	return 0;
 }
-#else
-int __init __weak early_init_dt_alloc_reserved_memory_arch(phys_addr_t size,
-	phys_addr_t align, phys_addr_t start, phys_addr_t end, bool nomap,
-	phys_addr_t *res_base)
-{
-	pr_err("Reserved memory not supported, ignoring region 0x%llx%s\n",
-		  size, nomap ? " (nomap)" : "");
-	return -ENOSYS;
-}
-#endif
 
 /**
  * res_mem_save_node() - save fdt node for second pass initialization
diff --git a/drivers/staging/android/ion/Kconfig b/drivers/staging/android/ion/Kconfig
index c16dd16..0fdda6f 100644
--- a/drivers/staging/android/ion/Kconfig
+++ b/drivers/staging/android/ion/Kconfig
@@ -1,6 +1,6 @@
 menuconfig ION
 	bool "Ion Memory Manager"
-	depends on HAVE_MEMBLOCK && HAS_DMA && MMU
+	depends on HAS_DMA && MMU
 	select GENERIC_ALLOCATOR
 	select DMA_SHARED_BUFFER
 	help
diff --git a/fs/pstore/Kconfig b/fs/pstore/Kconfig
index 503086f..0d19d19 100644
--- a/fs/pstore/Kconfig
+++ b/fs/pstore/Kconfig
@@ -141,7 +141,6 @@ config PSTORE_RAM
 	tristate "Log panic/oops to a RAM buffer"
 	depends on PSTORE
 	depends on HAS_IOMEM
-	depends on HAVE_MEMBLOCK
 	select REED_SOLOMON
 	select REED_SOLOMON_ENC8
 	select REED_SOLOMON_DEC8
diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index 1f005b5..ee61ac3 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -132,9 +132,6 @@ extern void *__alloc_bootmem_low_node(pg_data_t *pgdat,
 #define alloc_bootmem_low_pages_node(pgdat, x) \
 	__alloc_bootmem_low_node(pgdat, x, PAGE_SIZE, 0)
 
-
-#if defined(CONFIG_HAVE_MEMBLOCK)
-
 /* FIXME: use MEMBLOCK_ALLOC_* variants here */
 #define BOOTMEM_ALLOC_ACCESSIBLE	0
 #define BOOTMEM_ALLOC_ANYWHERE		(~(phys_addr_t)0)
@@ -234,115 +231,6 @@ static inline void __init memblock_free_late(
 	__memblock_free_late(base, size);
 }
 
-#else
-
-#define BOOTMEM_ALLOC_ACCESSIBLE	0
-
-
-/* Fall back to all the existing bootmem APIs */
-static inline void * __init memblock_virt_alloc(
-					phys_addr_t size,  phys_addr_t align)
-{
-	if (!align)
-		align = SMP_CACHE_BYTES;
-	return __alloc_bootmem(size, align, BOOTMEM_LOW_LIMIT);
-}
-
-static inline void * __init memblock_virt_alloc_raw(
-					phys_addr_t size,  phys_addr_t align)
-{
-	if (!align)
-		align = SMP_CACHE_BYTES;
-	return __alloc_bootmem_nopanic(size, align, BOOTMEM_LOW_LIMIT);
-}
-
-static inline void * __init memblock_virt_alloc_nopanic(
-					phys_addr_t size, phys_addr_t align)
-{
-	if (!align)
-		align = SMP_CACHE_BYTES;
-	return __alloc_bootmem_nopanic(size, align, BOOTMEM_LOW_LIMIT);
-}
-
-static inline void * __init memblock_virt_alloc_low(
-					phys_addr_t size, phys_addr_t align)
-{
-	if (!align)
-		align = SMP_CACHE_BYTES;
-	return __alloc_bootmem_low(size, align, 0);
-}
-
-static inline void * __init memblock_virt_alloc_low_nopanic(
-					phys_addr_t size, phys_addr_t align)
-{
-	if (!align)
-		align = SMP_CACHE_BYTES;
-	return __alloc_bootmem_low_nopanic(size, align, 0);
-}
-
-static inline void * __init memblock_virt_alloc_from_nopanic(
-		phys_addr_t size, phys_addr_t align, phys_addr_t min_addr)
-{
-	return __alloc_bootmem_nopanic(size, align, min_addr);
-}
-
-static inline void * __init memblock_virt_alloc_node(
-						phys_addr_t size, int nid)
-{
-	return __alloc_bootmem_node(NODE_DATA(nid), size, SMP_CACHE_BYTES,
-				     BOOTMEM_LOW_LIMIT);
-}
-
-static inline void * __init memblock_virt_alloc_node_nopanic(
-						phys_addr_t size, int nid)
-{
-	return __alloc_bootmem_node_nopanic(NODE_DATA(nid), size,
-					     SMP_CACHE_BYTES,
-					     BOOTMEM_LOW_LIMIT);
-}
-
-static inline void * __init memblock_virt_alloc_try_nid(phys_addr_t size,
-	phys_addr_t align, phys_addr_t min_addr, phys_addr_t max_addr, int nid)
-{
-	return __alloc_bootmem_node_high(NODE_DATA(nid), size, align,
-					  min_addr);
-}
-
-static inline void * __init memblock_virt_alloc_try_nid_raw(
-			phys_addr_t size, phys_addr_t align,
-			phys_addr_t min_addr, phys_addr_t max_addr, int nid)
-{
-	return ___alloc_bootmem_node_nopanic(NODE_DATA(nid), size, align,
-				min_addr, max_addr);
-}
-
-static inline void * __init memblock_virt_alloc_try_nid_nopanic(
-			phys_addr_t size, phys_addr_t align,
-			phys_addr_t min_addr, phys_addr_t max_addr, int nid)
-{
-	return ___alloc_bootmem_node_nopanic(NODE_DATA(nid), size, align,
-				min_addr, max_addr);
-}
-
-static inline void __init memblock_free_early(
-					phys_addr_t base, phys_addr_t size)
-{
-	free_bootmem(base, size);
-}
-
-static inline void __init memblock_free_early_nid(
-				phys_addr_t base, phys_addr_t size, int nid)
-{
-	free_bootmem_node(NODE_DATA(nid), base, size);
-}
-
-static inline void __init memblock_free_late(
-					phys_addr_t base, phys_addr_t size)
-{
-	free_bootmem_late(base, size);
-}
-#endif /* defined(CONFIG_HAVE_MEMBLOCK) */
-
 extern void *alloc_large_system_hash(const char *tablename,
 				     unsigned long bucketsize,
 				     unsigned long numentries,
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 58697ad..3c96a16 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -2,7 +2,6 @@
 #define _LINUX_MEMBLOCK_H
 #ifdef __KERNEL__
 
-#ifdef CONFIG_HAVE_MEMBLOCK
 /*
  * Logical memory blocks.
  *
@@ -462,7 +461,6 @@ static inline phys_addr_t memblock_alloc(phys_addr_t size, phys_addr_t align)
 {
 	return 0;
 }
-#endif /* CONFIG_HAVE_MEMBLOCK */
 
 #endif /* __KERNEL__ */
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index bd5e246..6215168 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2143,7 +2143,7 @@ extern int __meminit __early_pfn_to_nid(unsigned long pfn,
 					struct mminit_pfnnid_cache *state);
 #endif
 
-#if defined(CONFIG_HAVE_MEMBLOCK) && !defined(CONFIG_FLAT_NODE_MEM_MAP)
+#if !defined(CONFIG_FLAT_NODE_MEM_MAP)
 void zero_resv_unavail(void);
 #else
 static inline void zero_resv_unavail(void) {}
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 121d869..321117f 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1311,7 +1311,7 @@ config DEBUG_KOBJECT
 	depends on DEBUG_KERNEL
 	help
 	  If you say Y here, some extra kobject debugging messages will be sent
-	  to the syslog. 
+	  to the syslog.
 
 config DEBUG_KOBJECT_RELEASE
 	bool "kobject release debugging"
@@ -1988,7 +1988,6 @@ endif # RUNTIME_TESTING_MENU
 
 config MEMTEST
 	bool "Memtest"
-	depends on HAVE_MEMBLOCK
 	---help---
 	  This option adds a kernel parameter 'memtest', which allows memtest
 	  to be set.
diff --git a/mm/Kconfig b/mm/Kconfig
index 16ceea0..c6a0d82 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -127,9 +127,6 @@ config SPARSEMEM_VMEMMAP
 	 pfn_to_page and page_to_pfn operations.  This is the most
 	 efficient option when sufficient kernel resources are available.
 
-config HAVE_MEMBLOCK
-	bool
-
 config HAVE_MEMBLOCK_NODE_MAP
 	bool
 
@@ -481,7 +478,7 @@ config FRONTSWAP
 
 config CMA
 	bool "Contiguous Memory Allocator"
-	depends on HAVE_MEMBLOCK && MMU
+	depends on MMU
 	select MIGRATION
 	select MEMORY_ISOLATION
 	help
diff --git a/mm/Makefile b/mm/Makefile
index c4da6de..0a3e72e 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -43,11 +43,11 @@ obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
 
 obj-y += init-mm.o
 obj-y += nobootmem.o
+obj-y += memblock.o
 
 ifdef CONFIG_MMU
 	obj-$(CONFIG_ADVISE_SYSCALLS)	+= madvise.o
 endif
-obj-$(CONFIG_HAVE_MEMBLOCK) += memblock.o
 
 obj-$(CONFIG_SWAP)	+= page_io.o swap_state.o swapfile.o swap_slots.o
 obj-$(CONFIG_FRONTSWAP)	+= frontswap.o
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index 439af3b..d4d0cd4 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -23,10 +23,6 @@
 
 #include "internal.h"
 
-#ifndef CONFIG_HAVE_MEMBLOCK
-#error CONFIG_HAVE_MEMBLOCK not defined
-#endif
-
 #ifndef CONFIG_NEED_MULTIPLE_NODES
 struct pglist_data __refdata contig_page_data;
 EXPORT_SYMBOL(contig_page_data);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 61e664d..a4985cd 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6442,7 +6442,7 @@ void __init free_area_init_node(int nid, unsigned long *zones_size,
 	free_area_init_core(pgdat);
 }
 
-#if defined(CONFIG_HAVE_MEMBLOCK) && !defined(CONFIG_FLAT_NODE_MEM_MAP)
+#if !defined(CONFIG_FLAT_NODE_MEM_MAP)
 /*
  * Only struct pages that are backed by physical memory are zeroed and
  * initialized by going through __init_single_page(). But, there are some
@@ -6483,7 +6483,7 @@ void __init zero_resv_unavail(void)
 	if (pgcnt)
 		pr_info("Reserved but unavailable: %lld pages", pgcnt);
 }
-#endif /* CONFIG_HAVE_MEMBLOCK && !CONFIG_FLAT_NODE_MEM_MAP */
+#endif /* !CONFIG_FLAT_NODE_MEM_MAP */
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 
-- 
2.7.4
