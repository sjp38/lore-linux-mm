Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 905536B00FD
	for <linux-mm@kvack.org>; Tue, 25 Jan 2011 12:59:35 -0500 (EST)
Message-Id: <20110125174907.720761184@chello.nl>
Date: Tue, 25 Jan 2011 18:31:21 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 10/25] mm: Now that all old mmu_gather code is gone, remove the storage
References: <20110125173111.720927511@chello.nl>
Content-Disposition: inline; filename=arch-remove-mmu_gather.patch
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>, Avi Kivity <avi@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Yanmin Zhang <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

XXX fold all the mmu_gather preempt patches into one for submission

Reported-by: Hugh Dickins <hughd@google.com>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/alpha/mm/init.c      |    2 --
 arch/arm/mm/mmu.c         |    2 --
 arch/avr32/mm/init.c      |    2 --
 arch/cris/mm/init.c       |    2 --
 arch/frv/mm/init.c        |    2 --
 arch/ia64/mm/init.c       |    2 --
 arch/m32r/mm/init.c       |    2 --
 arch/m68k/mm/init.c       |    2 --
 arch/microblaze/mm/init.c |    2 --
 arch/mips/mm/init.c       |    2 --
 arch/mn10300/mm/init.c    |    2 --
 arch/parisc/mm/init.c     |    2 --
 arch/s390/mm/pgtable.c    |    1 -
 arch/score/mm/init.c      |    2 --
 arch/sh/mm/init.c         |    1 -
 arch/sparc/mm/init_32.c   |    2 --
 arch/tile/mm/init.c       |    2 --
 arch/um/kernel/smp.c      |    3 ---
 arch/x86/mm/init.c        |    2 --
 arch/xtensa/mm/mmu.c      |    2 --
 20 files changed, 39 deletions(-)

Index: linux-2.6/arch/alpha/mm/init.c
===================================================================
--- linux-2.6.orig/arch/alpha/mm/init.c
+++ linux-2.6/arch/alpha/mm/init.c
@@ -32,8 +32,6 @@
 #include <asm/console.h>
 #include <asm/tlb.h>
 
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
-
 extern void die_if_kernel(char *,struct pt_regs *,long);
 
 static struct pcb_struct original_pcb;
Index: linux-2.6/arch/arm/mm/mmu.c
===================================================================
--- linux-2.6.orig/arch/arm/mm/mmu.c
+++ linux-2.6/arch/arm/mm/mmu.c
@@ -31,8 +31,6 @@
 
 #include "mm.h"
 
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
-
 /*
  * empty_zero_page is a special page that is used for
  * zero-initialized data and COW.
Index: linux-2.6/arch/avr32/mm/init.c
===================================================================
--- linux-2.6.orig/arch/avr32/mm/init.c
+++ linux-2.6/arch/avr32/mm/init.c
@@ -25,8 +25,6 @@
 #include <asm/setup.h>
 #include <asm/sections.h>
 
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
-
 pgd_t swapper_pg_dir[PTRS_PER_PGD] __page_aligned_data;
 
 struct page *empty_zero_page;
Index: linux-2.6/arch/cris/mm/init.c
===================================================================
--- linux-2.6.orig/arch/cris/mm/init.c
+++ linux-2.6/arch/cris/mm/init.c
@@ -13,8 +13,6 @@
 #include <linux/bootmem.h>
 #include <asm/tlb.h>
 
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
-
 unsigned long empty_zero_page;
 
 extern char _stext, _edata, _etext; /* From linkerscript */
Index: linux-2.6/arch/frv/mm/init.c
===================================================================
--- linux-2.6.orig/arch/frv/mm/init.c
+++ linux-2.6/arch/frv/mm/init.c
@@ -41,8 +41,6 @@
 
 #undef DEBUG
 
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
-
 /*
  * BAD_PAGE is the page that is used for page faults when linux
  * is out-of-memory. Older versions of linux just did a
Index: linux-2.6/arch/ia64/mm/init.c
===================================================================
--- linux-2.6.orig/arch/ia64/mm/init.c
+++ linux-2.6/arch/ia64/mm/init.c
@@ -36,8 +36,6 @@
 #include <asm/mca.h>
 #include <asm/paravirt.h>
 
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
-
 extern void ia64_tlb_init (void);
 
 unsigned long MAX_DMA_ADDRESS = PAGE_OFFSET + 0x100000000UL;
Index: linux-2.6/arch/m32r/mm/init.c
===================================================================
--- linux-2.6.orig/arch/m32r/mm/init.c
+++ linux-2.6/arch/m32r/mm/init.c
@@ -35,8 +35,6 @@ extern char __init_begin, __init_end;
 
 pgd_t swapper_pg_dir[1024];
 
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
-
 /*
  * Cache of MMU context last used.
  */
Index: linux-2.6/arch/m68k/mm/init.c
===================================================================
--- linux-2.6.orig/arch/m68k/mm/init.c
+++ linux-2.6/arch/m68k/mm/init.c
@@ -32,8 +32,6 @@
 #include <asm/sections.h>
 #include <asm/tlb.h>
 
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
-
 pg_data_t pg_data_map[MAX_NUMNODES];
 EXPORT_SYMBOL(pg_data_map);
 
Index: linux-2.6/arch/microblaze/mm/init.c
===================================================================
--- linux-2.6.orig/arch/microblaze/mm/init.c
+++ linux-2.6/arch/microblaze/mm/init.c
@@ -32,8 +32,6 @@ unsigned int __page_offset;
 EXPORT_SYMBOL(__page_offset);
 
 #else
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
-
 static int init_bootmem_done;
 #endif /* CONFIG_MMU */
 
Index: linux-2.6/arch/mips/mm/init.c
===================================================================
--- linux-2.6.orig/arch/mips/mm/init.c
+++ linux-2.6/arch/mips/mm/init.c
@@ -64,8 +64,6 @@
 
 #endif /* CONFIG_MIPS_MT_SMTC */
 
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
-
 /*
  * We have up to 8 empty zeroed pages so we can map one of the right colour
  * when needed.  This is necessary only on R4000 / R4400 SC and MC versions
Index: linux-2.6/arch/mn10300/mm/init.c
===================================================================
--- linux-2.6.orig/arch/mn10300/mm/init.c
+++ linux-2.6/arch/mn10300/mm/init.c
@@ -37,8 +37,6 @@
 #include <asm/tlb.h>
 #include <asm/sections.h>
 
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
-
 unsigned long highstart_pfn, highend_pfn;
 
 #ifdef CONFIG_MN10300_HAS_ATOMIC_OPS_UNIT
Index: linux-2.6/arch/parisc/mm/init.c
===================================================================
--- linux-2.6.orig/arch/parisc/mm/init.c
+++ linux-2.6/arch/parisc/mm/init.c
@@ -31,8 +31,6 @@
 #include <asm/mmzone.h>
 #include <asm/sections.h>
 
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
-
 extern int  data_start;
 
 #ifdef CONFIG_DISCONTIGMEM
Index: linux-2.6/arch/s390/mm/pgtable.c
===================================================================
--- linux-2.6.orig/arch/s390/mm/pgtable.c
+++ linux-2.6/arch/s390/mm/pgtable.c
@@ -36,7 +36,6 @@ struct rcu_table_freelist {
 	((PAGE_SIZE - sizeof(struct rcu_table_freelist)) \
 	  / sizeof(unsigned long))
 
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
 static DEFINE_PER_CPU(struct rcu_table_freelist *, rcu_table_freelist);
 
 static void __page_table_free(struct mm_struct *mm, unsigned long *table);
Index: linux-2.6/arch/score/mm/init.c
===================================================================
--- linux-2.6.orig/arch/score/mm/init.c
+++ linux-2.6/arch/score/mm/init.c
@@ -38,8 +38,6 @@
 #include <asm/sections.h>
 #include <asm/tlb.h>
 
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
-
 unsigned long empty_zero_page;
 EXPORT_SYMBOL_GPL(empty_zero_page);
 
Index: linux-2.6/arch/sh/mm/init.c
===================================================================
--- linux-2.6.orig/arch/sh/mm/init.c
+++ linux-2.6/arch/sh/mm/init.c
@@ -28,7 +28,6 @@
 #include <asm/cache.h>
 #include <asm/sizes.h>
 
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
 pgd_t swapper_pg_dir[PTRS_PER_PGD];
 
 void __init generic_mem_init(void)
Index: linux-2.6/arch/sparc/mm/init_32.c
===================================================================
--- linux-2.6.orig/arch/sparc/mm/init_32.c
+++ linux-2.6/arch/sparc/mm/init_32.c
@@ -37,8 +37,6 @@
 #include <asm/prom.h>
 #include <asm/leon.h>
 
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
-
 unsigned long *sparc_valid_addr_bitmap;
 EXPORT_SYMBOL(sparc_valid_addr_bitmap);
 
Index: linux-2.6/arch/tile/mm/init.c
===================================================================
--- linux-2.6.orig/arch/tile/mm/init.c
+++ linux-2.6/arch/tile/mm/init.c
@@ -71,8 +71,6 @@
 unsigned long VMALLOC_RESERVE = CONFIG_VMALLOC_RESERVE;
 #endif
 
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
-
 /* Create an L2 page table */
 static pte_t * __init alloc_pte(void)
 {
Index: linux-2.6/arch/um/kernel/smp.c
===================================================================
--- linux-2.6.orig/arch/um/kernel/smp.c
+++ linux-2.6/arch/um/kernel/smp.c
@@ -7,9 +7,6 @@
 #include "asm/pgalloc.h"
 #include "asm/tlb.h"
 
-/* For some reason, mmu_gathers are referenced when CONFIG_SMP is off. */
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
-
 #ifdef CONFIG_SMP
 
 #include "linux/sched.h"
Index: linux-2.6/arch/x86/mm/init.c
===================================================================
--- linux-2.6.orig/arch/x86/mm/init.c
+++ linux-2.6/arch/x86/mm/init.c
@@ -16,8 +16,6 @@
 #include <asm/tlb.h>
 #include <asm/proto.h>
 
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
-
 unsigned long __initdata e820_table_start;
 unsigned long __meminitdata e820_table_end;
 unsigned long __meminitdata e820_table_top;
Index: linux-2.6/arch/xtensa/mm/mmu.c
===================================================================
--- linux-2.6.orig/arch/xtensa/mm/mmu.c
+++ linux-2.6/arch/xtensa/mm/mmu.c
@@ -14,8 +14,6 @@
 #include <asm/mmu_context.h>
 #include <asm/page.h>
 
-DEFINE_PER_CPU(struct mmu_gather, mmu_gathers);
-
 void __init paging_init(void)
 {
 	memset(swapper_pg_dir, 0, PAGE_SIZE);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
