Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id D81838E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:13:43 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id s200-v6so9323185oie.6
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 05:13:43 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id c61-v6si1431807otb.298.2018.09.14.05.13.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 05:13:41 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8EC5IEF093502
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:13:41 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mg9yyeuq9-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:13:40 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 14 Sep 2018 13:13:37 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 25/30] memblock: rename free_all_bootmem to memblock_free_all
Date: Fri, 14 Sep 2018 15:10:40 +0300
In-Reply-To: <1536927045-23536-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1536927045-23536-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1536927045-23536-26-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Chris Zankel <chris@zankel.net>, "David S. Miller" <davem@davemloft.net>, Geert Uytterhoeven <geert@linux-m68k.org>, Greentime Hu <green.hu@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao <gxt@pku.edu.cn>, Ingo Molnar <mingo@redhat.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Jonas Bonn <jonas@southpole.se>, Jonathan Corbet <corbet@lwn.net>, Ley Foon Tan <lftan@altera.com>, Mark Salter <msalter@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Matt Turner <mattst88@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Michal Simek <monstr@monstr.eu>, Palmer Dabbelt <palmer@sifive.com>, Paul Burton <paul.burton@mips.com>, Richard Kuo <rkuo@codeaurora.org>, Richard Weinberger <richard@nod.at>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Serge Semin <fancer.lancer@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp, Mike Rapoport <rppt@linux.vnet.ibm.com>

The conversion is done using

sed -i 's@free_all_bootmem@memblock_free_all@' \
    $(git grep -l free_all_bootmem)

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 arch/alpha/mm/init.c                   | 2 +-
 arch/arc/mm/init.c                     | 2 +-
 arch/arm/mm/init.c                     | 2 +-
 arch/arm64/mm/init.c                   | 2 +-
 arch/c6x/mm/init.c                     | 2 +-
 arch/h8300/mm/init.c                   | 2 +-
 arch/hexagon/mm/init.c                 | 2 +-
 arch/ia64/mm/init.c                    | 2 +-
 arch/m68k/mm/init.c                    | 2 +-
 arch/microblaze/mm/init.c              | 2 +-
 arch/mips/loongson64/loongson-3/numa.c | 2 +-
 arch/mips/mm/init.c                    | 2 +-
 arch/mips/sgi-ip27/ip27-memory.c       | 2 +-
 arch/nds32/mm/init.c                   | 2 +-
 arch/nios2/mm/init.c                   | 2 +-
 arch/openrisc/mm/init.c                | 2 +-
 arch/parisc/mm/init.c                  | 2 +-
 arch/powerpc/mm/mem.c                  | 2 +-
 arch/riscv/mm/init.c                   | 2 +-
 arch/s390/mm/init.c                    | 2 +-
 arch/sh/mm/init.c                      | 2 +-
 arch/sparc/mm/init_32.c                | 2 +-
 arch/sparc/mm/init_64.c                | 4 ++--
 arch/um/kernel/mem.c                   | 2 +-
 arch/unicore32/mm/init.c               | 2 +-
 arch/x86/mm/highmem_32.c               | 2 +-
 arch/x86/mm/init_32.c                  | 4 ++--
 arch/x86/mm/init_64.c                  | 4 ++--
 arch/x86/xen/mmu_pv.c                  | 2 +-
 arch/xtensa/mm/init.c                  | 2 +-
 include/linux/bootmem.h                | 2 +-
 mm/memblock.c                          | 2 +-
 mm/nobootmem.c                         | 4 ++--
 mm/page_alloc.c                        | 2 +-
 mm/page_poison.c                       | 2 +-
 35 files changed, 39 insertions(+), 39 deletions(-)

diff --git a/arch/alpha/mm/init.c b/arch/alpha/mm/init.c
index 9d74520..853d153 100644
--- a/arch/alpha/mm/init.c
+++ b/arch/alpha/mm/init.c
@@ -282,7 +282,7 @@ mem_init(void)
 {
 	set_max_mapnr(max_low_pfn);
 	high_memory = (void *) __va(max_low_pfn * PAGE_SIZE);
-	free_all_bootmem();
+	memblock_free_all();
 	mem_init_print_info(NULL);
 }
 
diff --git a/arch/arc/mm/init.c b/arch/arc/mm/init.c
index ba14506..0f29c65 100644
--- a/arch/arc/mm/init.c
+++ b/arch/arc/mm/init.c
@@ -218,7 +218,7 @@ void __init mem_init(void)
 		free_highmem_page(pfn_to_page(tmp));
 #endif
 
-	free_all_bootmem();
+	memblock_free_all();
 	mem_init_print_info(NULL);
 }
 
diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index 0cc8e04..d421a10 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -508,7 +508,7 @@ void __init mem_init(void)
 
 	/* this will put all unused low memory onto the freelists */
 	free_unused_memmap();
-	free_all_bootmem();
+	memblock_free_all();
 
 #ifdef CONFIG_SA1111
 	/* now that our DMA memory is actually so designated, we can free it */
diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index e335452..ae21849 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -601,7 +601,7 @@ void __init mem_init(void)
 	free_unused_memmap();
 #endif
 	/* this will put all unused low memory onto the freelists */
-	free_all_bootmem();
+	memblock_free_all();
 
 	kexec_reserve_crashkres_pages();
 
diff --git a/arch/c6x/mm/init.c b/arch/c6x/mm/init.c
index dc369ad..3383df8 100644
--- a/arch/c6x/mm/init.c
+++ b/arch/c6x/mm/init.c
@@ -62,7 +62,7 @@ void __init mem_init(void)
 	high_memory = (void *)(memory_end & PAGE_MASK);
 
 	/* this will put all memory onto the freelists */
-	free_all_bootmem();
+	memblock_free_all();
 
 	mem_init_print_info(NULL);
 }
diff --git a/arch/h8300/mm/init.c b/arch/h8300/mm/init.c
index 5d31ac9..f2bf448 100644
--- a/arch/h8300/mm/init.c
+++ b/arch/h8300/mm/init.c
@@ -96,7 +96,7 @@ void __init mem_init(void)
 	max_mapnr = MAP_NR(high_memory);
 
 	/* this will put all low memory onto the freelists */
-	free_all_bootmem();
+	memblock_free_all();
 
 	mem_init_print_info(NULL);
 }
diff --git a/arch/hexagon/mm/init.c b/arch/hexagon/mm/init.c
index d789b9c..88643fa 100644
--- a/arch/hexagon/mm/init.c
+++ b/arch/hexagon/mm/init.c
@@ -68,7 +68,7 @@ unsigned long long kmap_generation;
 void __init mem_init(void)
 {
 	/*  No idea where this is actually declared.  Seems to evade LXR.  */
-	free_all_bootmem();
+	memblock_free_all();
 	mem_init_print_info(NULL);
 
 	/*
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index 2169ca5..43ea4a4 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -627,7 +627,7 @@ mem_init (void)
 
 	set_max_mapnr(max_low_pfn);
 	high_memory = __va(max_low_pfn * PAGE_SIZE);
-	free_all_bootmem();
+	memblock_free_all();
 	mem_init_print_info(NULL);
 
 	/*
diff --git a/arch/m68k/mm/init.c b/arch/m68k/mm/init.c
index 977363e..ae49ae4 100644
--- a/arch/m68k/mm/init.c
+++ b/arch/m68k/mm/init.c
@@ -140,7 +140,7 @@ static inline void init_pointer_tables(void)
 void __init mem_init(void)
 {
 	/* this will put all memory onto the freelists */
-	free_all_bootmem();
+	memblock_free_all();
 	init_pointer_tables();
 	mem_init_print_info(NULL);
 }
diff --git a/arch/microblaze/mm/init.c b/arch/microblaze/mm/init.c
index 8c7f074..9989740 100644
--- a/arch/microblaze/mm/init.c
+++ b/arch/microblaze/mm/init.c
@@ -204,7 +204,7 @@ void __init mem_init(void)
 	high_memory = (void *)__va(memory_start + lowmem_size - 1);
 
 	/* this will put all memory onto the freelists */
-	free_all_bootmem();
+	memblock_free_all();
 #ifdef CONFIG_HIGHMEM
 	highmem_setup();
 #endif
diff --git a/arch/mips/loongson64/loongson-3/numa.c b/arch/mips/loongson64/loongson-3/numa.c
index c1e6ec5..703ad45 100644
--- a/arch/mips/loongson64/loongson-3/numa.c
+++ b/arch/mips/loongson64/loongson-3/numa.c
@@ -272,7 +272,7 @@ void __init paging_init(void)
 void __init mem_init(void)
 {
 	high_memory = (void *) __va(get_num_physpages() << PAGE_SHIFT);
-	free_all_bootmem();
+	memblock_free_all();
 	setup_zero_pages();	/* This comes from node 0 */
 	mem_init_print_info(NULL);
 }
diff --git a/arch/mips/mm/init.c b/arch/mips/mm/init.c
index a010fba7..54c36be 100644
--- a/arch/mips/mm/init.c
+++ b/arch/mips/mm/init.c
@@ -464,7 +464,7 @@ void __init mem_init(void)
 	high_memory = (void *) __va(max_low_pfn << PAGE_SHIFT);
 
 	maar_init();
-	free_all_bootmem();
+	memblock_free_all();
 	setup_zero_pages();	/* Setup zeroed pages.  */
 	mem_init_free_highmem();
 	mem_init_print_info(NULL);
diff --git a/arch/mips/sgi-ip27/ip27-memory.c b/arch/mips/sgi-ip27/ip27-memory.c
index 6f7bef0..cb1f1a6 100644
--- a/arch/mips/sgi-ip27/ip27-memory.c
+++ b/arch/mips/sgi-ip27/ip27-memory.c
@@ -475,7 +475,7 @@ void __init paging_init(void)
 void __init mem_init(void)
 {
 	high_memory = (void *) __va(get_num_physpages() << PAGE_SHIFT);
-	free_all_bootmem();
+	memblock_free_all();
 	setup_zero_pages();	/* This comes from node 0 */
 	mem_init_print_info(NULL);
 }
diff --git a/arch/nds32/mm/init.c b/arch/nds32/mm/init.c
index 5af81b8..66d3e9c 100644
--- a/arch/nds32/mm/init.c
+++ b/arch/nds32/mm/init.c
@@ -192,7 +192,7 @@ void __init mem_init(void)
 	free_highmem();
 
 	/* this will put all low memory onto the freelists */
-	free_all_bootmem();
+	memblock_free_all();
 	mem_init_print_info(NULL);
 
 	pr_info("virtual kernel memory layout:\n"
diff --git a/arch/nios2/mm/init.c b/arch/nios2/mm/init.c
index c92fe42..1292350 100644
--- a/arch/nios2/mm/init.c
+++ b/arch/nios2/mm/init.c
@@ -73,7 +73,7 @@ void __init mem_init(void)
 	high_memory = __va(end_mem);
 
 	/* this will put all memory onto the freelists */
-	free_all_bootmem();
+	memblock_free_all();
 	mem_init_print_info(NULL);
 }
 
diff --git a/arch/openrisc/mm/init.c b/arch/openrisc/mm/init.c
index b7670de..91a6a9a 100644
--- a/arch/openrisc/mm/init.c
+++ b/arch/openrisc/mm/init.c
@@ -213,7 +213,7 @@ void __init mem_init(void)
 	memset((void *)empty_zero_page, 0, PAGE_SIZE);
 
 	/* this will put all low memory onto the freelists */
-	free_all_bootmem();
+	memblock_free_all();
 
 	mem_init_print_info(NULL);
 
diff --git a/arch/parisc/mm/init.c b/arch/parisc/mm/init.c
index 74842d2..bc368e9 100644
--- a/arch/parisc/mm/init.c
+++ b/arch/parisc/mm/init.c
@@ -612,7 +612,7 @@ void __init mem_init(void)
 
 	high_memory = __va((max_pfn << PAGE_SHIFT));
 	set_max_mapnr(page_to_pfn(virt_to_page(high_memory - 1)) + 1);
-	free_all_bootmem();
+	memblock_free_all();
 
 #ifdef CONFIG_PA11
 	if (boot_cpu_data.cpu_type == pcxl2 || boot_cpu_data.cpu_type == pcxl) {
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index 5c8530d..c141134 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -348,7 +348,7 @@ void __init mem_init(void)
 
 	high_memory = (void *) __va(max_low_pfn * PAGE_SIZE);
 	set_max_mapnr(max_pfn);
-	free_all_bootmem();
+	memblock_free_all();
 
 #ifdef CONFIG_HIGHMEM
 	{
diff --git a/arch/riscv/mm/init.c b/arch/riscv/mm/init.c
index 58a522f..d58c111 100644
--- a/arch/riscv/mm/init.c
+++ b/arch/riscv/mm/init.c
@@ -55,7 +55,7 @@ void __init mem_init(void)
 #endif /* CONFIG_FLATMEM */
 
 	high_memory = (void *)(__va(PFN_PHYS(max_low_pfn)));
-	free_all_bootmem();
+	memblock_free_all();
 
 	mem_init_print_info(NULL);
 }
diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index 3fa3e53..67bdba6 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -136,7 +136,7 @@ void __init mem_init(void)
 	cmma_init();
 
 	/* this will put all low memory onto the freelists */
-	free_all_bootmem();
+	memblock_free_all();
 	setup_zero_pages();	/* Setup zeroed pages. */
 
 	cmma_init_nodat();
diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index c884b76..21447f8 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -350,7 +350,7 @@ void __init mem_init(void)
 		high_memory = max_t(void *, high_memory,
 				    __va(pgdat_end_pfn(pgdat) << PAGE_SHIFT));
 
-	free_all_bootmem();
+	memblock_free_all();
 
 	/* Set this up early, so we can take care of the zero page */
 	cpu_cache_init();
diff --git a/arch/sparc/mm/init_32.c b/arch/sparc/mm/init_32.c
index 885dd38..8807145 100644
--- a/arch/sparc/mm/init_32.c
+++ b/arch/sparc/mm/init_32.c
@@ -277,7 +277,7 @@ void __init mem_init(void)
 
 	max_mapnr = last_valid_pfn - pfn_base;
 	high_memory = __va(max_low_pfn << PAGE_SHIFT);
-	free_all_bootmem();
+	memblock_free_all();
 
 	for (i = 0; sp_banks[i].num_bytes != 0; i++) {
 		unsigned long start_pfn = sp_banks[i].base_addr >> PAGE_SHIFT;
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index 51cd583..c2c8bff 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -2544,12 +2544,12 @@ void __init mem_init(void)
 {
 	high_memory = __va(last_valid_pfn << PAGE_SHIFT);
 
-	free_all_bootmem();
+	memblock_free_all();
 
 	/*
 	 * Must be done after boot memory is put on freelist, because here we
 	 * might set fields in deferred struct pages that have not yet been
-	 * initialized, and free_all_bootmem() initializes all the reserved
+	 * initialized, and memblock_free_all() initializes all the reserved
 	 * deferred pages for us.
 	 */
 	register_page_bootmem_info();
diff --git a/arch/um/kernel/mem.c b/arch/um/kernel/mem.c
index 3555c13..2c672a8 100644
--- a/arch/um/kernel/mem.c
+++ b/arch/um/kernel/mem.c
@@ -51,7 +51,7 @@ void __init mem_init(void)
 	uml_reserved = brk_end;
 
 	/* this will put all low memory onto the freelists */
-	free_all_bootmem();
+	memblock_free_all();
 	max_low_pfn = totalram_pages;
 	max_pfn = totalram_pages;
 	mem_init_print_info(NULL);
diff --git a/arch/unicore32/mm/init.c b/arch/unicore32/mm/init.c
index 4c572ab..3e5bb45 100644
--- a/arch/unicore32/mm/init.c
+++ b/arch/unicore32/mm/init.c
@@ -289,7 +289,7 @@ void __init mem_init(void)
 	free_unused_memmap(&meminfo);
 
 	/* this will put all unused low memory onto the freelists */
-	free_all_bootmem();
+	memblock_free_all();
 
 	mem_init_print_info(NULL);
 	printk(KERN_NOTICE "Virtual kernel memory layout:\n"
diff --git a/arch/x86/mm/highmem_32.c b/arch/x86/mm/highmem_32.c
index 6d18b70..62915a5 100644
--- a/arch/x86/mm/highmem_32.c
+++ b/arch/x86/mm/highmem_32.c
@@ -111,7 +111,7 @@ void __init set_highmem_pages_init(void)
 
 	/*
 	 * Explicitly reset zone->managed_pages because set_highmem_pages_init()
-	 * is invoked before free_all_bootmem()
+	 * is invoked before memblock_free_all()
 	 */
 	reset_all_zones_managed_pages();
 	for_each_zone(zone) {
diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 979e0a0..8ee1e64 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -771,7 +771,7 @@ void __init mem_init(void)
 #endif
 	/*
 	 * With CONFIG_DEBUG_PAGEALLOC initialization of highmem pages has to
-	 * be done before free_all_bootmem(). Memblock use free low memory for
+	 * be done before memblock_free_all(). Memblock use free low memory for
 	 * temporary data (see find_range_array()) and for this purpose can use
 	 * pages that was already passed to the buddy allocator, hence marked as
 	 * not accessible in the page tables when compiled with
@@ -781,7 +781,7 @@ void __init mem_init(void)
 	set_highmem_pages_init();
 
 	/* this will put all low memory onto the freelists */
-	free_all_bootmem();
+	memblock_free_all();
 
 	after_bootmem = 1;
 	x86_init.hyper.init_after_bootmem();
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index f39b512..bfb0bed 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1188,14 +1188,14 @@ void __init mem_init(void)
 	/* clear_bss() already clear the empty_zero_page */
 
 	/* this will put all memory onto the freelists */
-	free_all_bootmem();
+	memblock_free_all();
 	after_bootmem = 1;
 	x86_init.hyper.init_after_bootmem();
 
 	/*
 	 * Must be done after boot memory is put on freelist, because here we
 	 * might set fields in deferred struct pages that have not yet been
-	 * initialized, and free_all_bootmem() initializes all the reserved
+	 * initialized, and memblock_free_all() initializes all the reserved
 	 * deferred pages for us.
 	 */
 	register_page_bootmem_info();
diff --git a/arch/x86/xen/mmu_pv.c b/arch/x86/xen/mmu_pv.c
index 7ada9e4..93b54a8 100644
--- a/arch/x86/xen/mmu_pv.c
+++ b/arch/x86/xen/mmu_pv.c
@@ -864,7 +864,7 @@ static int __init xen_mark_pinned(struct mm_struct *mm, struct page *page,
  * The init_mm pagetable is really pinned as soon as its created, but
  * that's before we have page structures to store the bits.  So do all
  * the book-keeping now once struct pages for allocated pages are
- * initialized. This happens only after free_all_bootmem() is called.
+ * initialized. This happens only after memblock_free_all() is called.
  */
 static void __init xen_after_bootmem(void)
 {
diff --git a/arch/xtensa/mm/init.c b/arch/xtensa/mm/init.c
index 34aead7..f7fbe63 100644
--- a/arch/xtensa/mm/init.c
+++ b/arch/xtensa/mm/init.c
@@ -152,7 +152,7 @@ void __init mem_init(void)
 	max_mapnr = max_pfn - ARCH_PFN_OFFSET;
 	high_memory = (void *)__va(max_low_pfn << PAGE_SHIFT);
 
-	free_all_bootmem();
+	memblock_free_all();
 
 	mem_init_print_info(NULL);
 	pr_info("virtual kernel memory layout:\n"
diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index bcc7e2f..b58873a 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -26,7 +26,7 @@ extern unsigned long max_pfn;
  */
 extern unsigned long long max_possible_pfn;
 
-extern unsigned long free_all_bootmem(void);
+extern unsigned long memblock_free_all(void);
 extern void reset_node_managed_pages(pg_data_t *pgdat);
 extern void reset_all_zones_managed_pages(void);
 
diff --git a/mm/memblock.c b/mm/memblock.c
index 3a21476..1534edb 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1411,7 +1411,7 @@ static void * __init memblock_alloc_internal(
 	/*
 	 * Detect any accidental use of these APIs after slab is ready, as at
 	 * this moment memblock may be deinitialized already and its
-	 * internal data may be destroyed (after execution of free_all_bootmem)
+	 * internal data may be destroyed (after execution of memblock_free_all)
 	 */
 	if (WARN_ON_ONCE(slab_is_available()))
 		return kzalloc_node(size, GFP_NOWAIT, nid);
diff --git a/mm/nobootmem.c b/mm/nobootmem.c
index ee0f7fc..bb64b09 100644
--- a/mm/nobootmem.c
+++ b/mm/nobootmem.c
@@ -111,11 +111,11 @@ void __init reset_all_zones_managed_pages(void)
 }
 
 /**
- * free_all_bootmem - release free pages to the buddy allocator
+ * memblock_free_all - release free pages to the buddy allocator
  *
  * Return: the number of pages actually released.
  */
-unsigned long __init free_all_bootmem(void)
+unsigned long __init memblock_free_all(void)
 {
 	unsigned long pages;
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 7658a6f..13e394c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5472,7 +5472,7 @@ overlap_memmap_init(unsigned long zone, unsigned long *pfn)
 
 /*
  * Initially all pages are reserved - free ones are freed
- * up by free_all_bootmem() once the early boot process is
+ * up by memblock_free_all() once the early boot process is
  * done. Non-atomic initialization, single-pass.
  */
 void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
diff --git a/mm/page_poison.c b/mm/page_poison.c
index aa2b3d3..f7e2a67 100644
--- a/mm/page_poison.c
+++ b/mm/page_poison.c
@@ -21,7 +21,7 @@ bool page_poisoning_enabled(void)
 {
 	/*
 	 * Assumes that debug_pagealloc_enabled is set before
-	 * free_all_bootmem.
+	 * memblock_free_all.
 	 * Page poisoning is debug page alloc for some arches. If
 	 * either of those options are enabled, enable poisoning.
 	 */
-- 
2.7.4
