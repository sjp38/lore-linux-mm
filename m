Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3D1518E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:11:57 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id f11-v6so3505430otf.7
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 05:11:57 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id z36-v6si1538278otc.32.2018.09.14.05.11.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 05:11:53 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w8EC6LAi088143
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:11:53 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2mg9pb798x-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 08:11:52 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Fri, 14 Sep 2018 13:11:48 +0100
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: [PATCH 07/30] memblock: remove _virt from APIs returning virtual address
Date: Fri, 14 Sep 2018 15:10:22 +0300
In-Reply-To: <1536927045-23536-1-git-send-email-rppt@linux.vnet.ibm.com>
References: <1536927045-23536-1-git-send-email-rppt@linux.vnet.ibm.com>
Message-Id: <1536927045-23536-8-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Chris Zankel <chris@zankel.net>, "David S. Miller" <davem@davemloft.net>, Geert Uytterhoeven <geert@linux-m68k.org>, Greentime Hu <green.hu@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Guan Xuetao <gxt@pku.edu.cn>, Ingo Molnar <mingo@redhat.com>, "James E.J. Bottomley" <jejb@parisc-linux.org>, Jonas Bonn <jonas@southpole.se>, Jonathan Corbet <corbet@lwn.net>, Ley Foon Tan <lftan@altera.com>, Mark Salter <msalter@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Matt Turner <mattst88@gmail.com>, Michael Ellerman <mpe@ellerman.id.au>, Michal Hocko <mhocko@suse.com>, Michal Simek <monstr@monstr.eu>, Palmer Dabbelt <palmer@sifive.com>, Paul Burton <paul.burton@mips.com>, Richard Kuo <rkuo@codeaurora.org>, Richard Weinberger <richard@nod.at>, Rich Felker <dalias@libc.org>, Russell King <linux@armlinux.org.uk>, Serge Semin <fancer.lancer@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Tony Luck <tony.luck@intel.com>, Vineet Gupta <vgupta@synopsys.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-c6x-dev@linux-c6x.org, linux-hexagon@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-mips@linux-mips.org, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-um@lists.infradead.org, nios2-dev@lists.rocketboards.org, openrisc@lists.librecores.org, sparclinux@vger.kernel.org, uclinux-h8-devel@lists.sourceforge.jp, Mike Rapoport <rppt@linux.vnet.ibm.com>

The conversion is done using

sed -i 's@memblock_virt_alloc@memblock_alloc@g' \
	$(git grep -l memblock_virt_alloc)

Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
---
 arch/arm/kernel/setup.c                   |  4 ++--
 arch/arm/mach-omap2/omap_hwmod.c          |  6 ++---
 arch/arm64/mm/kasan_init.c                |  2 +-
 arch/arm64/mm/numa.c                      |  2 +-
 arch/mips/kernel/setup.c                  |  2 +-
 arch/powerpc/kernel/pci_32.c              |  2 +-
 arch/powerpc/lib/alloc.c                  |  2 +-
 arch/powerpc/mm/mmu_context_nohash.c      |  6 ++---
 arch/powerpc/platforms/powermac/nvram.c   |  2 +-
 arch/powerpc/platforms/powernv/pci-ioda.c |  6 ++---
 arch/powerpc/platforms/ps3/setup.c        |  2 +-
 arch/powerpc/sysdev/msi_bitmap.c          |  2 +-
 arch/s390/kernel/setup.c                  | 12 +++++-----
 arch/s390/kernel/smp.c                    |  2 +-
 arch/s390/kernel/topology.c               |  4 ++--
 arch/s390/numa/mode_emu.c                 |  2 +-
 arch/s390/numa/toptree.c                  |  2 +-
 arch/x86/mm/kasan_init_64.c               |  4 ++--
 arch/xtensa/mm/kasan_init.c               |  2 +-
 drivers/clk/ti/clk.c                      |  2 +-
 drivers/firmware/memmap.c                 |  2 +-
 drivers/of/fdt.c                          |  2 +-
 drivers/of/unittest.c                     |  2 +-
 include/linux/bootmem.h                   | 38 +++++++++++++++----------------
 init/main.c                               |  6 ++---
 kernel/dma/swiotlb.c                      |  8 +++----
 kernel/power/snapshot.c                   |  2 +-
 kernel/printk/printk.c                    |  4 ++--
 lib/cpumask.c                             |  2 +-
 mm/hugetlb.c                              |  2 +-
 mm/kasan/kasan_init.c                     |  2 +-
 mm/memblock.c                             | 26 ++++++++++-----------
 mm/page_alloc.c                           |  8 +++----
 mm/page_ext.c                             |  2 +-
 mm/percpu.c                               | 28 +++++++++++------------
 mm/sparse-vmemmap.c                       |  2 +-
 mm/sparse.c                               | 12 +++++-----
 37 files changed, 108 insertions(+), 108 deletions(-)

diff --git a/arch/arm/kernel/setup.c b/arch/arm/kernel/setup.c
index 4c249cb..39e6090 100644
--- a/arch/arm/kernel/setup.c
+++ b/arch/arm/kernel/setup.c
@@ -857,7 +857,7 @@ static void __init request_standard_resources(const struct machine_desc *mdesc)
 		 */
 		boot_alias_start = phys_to_idmap(start);
 		if (arm_has_idmap_alias() && boot_alias_start != IDMAP_INVALID_ADDR) {
-			res = memblock_virt_alloc(sizeof(*res), 0);
+			res = memblock_alloc(sizeof(*res), 0);
 			res->name = "System RAM (boot alias)";
 			res->start = boot_alias_start;
 			res->end = phys_to_idmap(end);
@@ -865,7 +865,7 @@ static void __init request_standard_resources(const struct machine_desc *mdesc)
 			request_resource(&iomem_resource, res);
 		}
 
-		res = memblock_virt_alloc(sizeof(*res), 0);
+		res = memblock_alloc(sizeof(*res), 0);
 		res->name  = "System RAM";
 		res->start = start;
 		res->end = end;
diff --git a/arch/arm/mach-omap2/omap_hwmod.c b/arch/arm/mach-omap2/omap_hwmod.c
index 56a1fe9..1f9b34a 100644
--- a/arch/arm/mach-omap2/omap_hwmod.c
+++ b/arch/arm/mach-omap2/omap_hwmod.c
@@ -726,7 +726,7 @@ static int __init _setup_clkctrl_provider(struct device_node *np)
 	u64 size;
 	int i;
 
-	provider = memblock_virt_alloc(sizeof(*provider), 0);
+	provider = memblock_alloc(sizeof(*provider), 0);
 	if (!provider)
 		return -ENOMEM;
 
@@ -736,12 +736,12 @@ static int __init _setup_clkctrl_provider(struct device_node *np)
 		of_property_count_elems_of_size(np, "reg", sizeof(u32)) / 2;
 
 	provider->addr =
-		memblock_virt_alloc(sizeof(void *) * provider->num_addrs, 0);
+		memblock_alloc(sizeof(void *) * provider->num_addrs, 0);
 	if (!provider->addr)
 		return -ENOMEM;
 
 	provider->size =
-		memblock_virt_alloc(sizeof(u32) * provider->num_addrs, 0);
+		memblock_alloc(sizeof(u32) * provider->num_addrs, 0);
 	if (!provider->size)
 		return -ENOMEM;
 
diff --git a/arch/arm64/mm/kasan_init.c b/arch/arm64/mm/kasan_init.c
index 1214587..2391560 100644
--- a/arch/arm64/mm/kasan_init.c
+++ b/arch/arm64/mm/kasan_init.c
@@ -38,7 +38,7 @@ static pgd_t tmp_pg_dir[PTRS_PER_PGD] __initdata __aligned(PGD_SIZE);
 
 static phys_addr_t __init kasan_alloc_zeroed_page(int node)
 {
-	void *p = memblock_virt_alloc_try_nid(PAGE_SIZE, PAGE_SIZE,
+	void *p = memblock_alloc_try_nid(PAGE_SIZE, PAGE_SIZE,
 					      __pa(MAX_DMA_ADDRESS),
 					      MEMBLOCK_ALLOC_ACCESSIBLE, node);
 	return __pa(p);
diff --git a/arch/arm64/mm/numa.c b/arch/arm64/mm/numa.c
index e5aacd6..8f2e0e8 100644
--- a/arch/arm64/mm/numa.c
+++ b/arch/arm64/mm/numa.c
@@ -168,7 +168,7 @@ static void * __init pcpu_fc_alloc(unsigned int cpu, size_t size,
 {
 	int nid = early_cpu_to_node(cpu);
 
-	return  memblock_virt_alloc_try_nid(size, align,
+	return  memblock_alloc_try_nid(size, align,
 			__pa(MAX_DMA_ADDRESS), MEMBLOCK_ALLOC_ACCESSIBLE, nid);
 }
 
diff --git a/arch/mips/kernel/setup.c b/arch/mips/kernel/setup.c
index 2fde53e..a717c90 100644
--- a/arch/mips/kernel/setup.c
+++ b/arch/mips/kernel/setup.c
@@ -851,7 +851,7 @@ static void __init arch_mem_init(char **cmdline_p)
 	 * Prevent memblock from allocating high memory.
 	 * This cannot be done before max_low_pfn is detected, so up
 	 * to this point is possible to only reserve physical memory
-	 * with memblock_reserve; memblock_virt_alloc* can be used
+	 * with memblock_reserve; memblock_alloc* can be used
 	 * only after this point
 	 */
 	memblock_set_current_limit(PFN_PHYS(max_low_pfn));
diff --git a/arch/powerpc/kernel/pci_32.c b/arch/powerpc/kernel/pci_32.c
index d63b488..2fb4781 100644
--- a/arch/powerpc/kernel/pci_32.c
+++ b/arch/powerpc/kernel/pci_32.c
@@ -204,7 +204,7 @@ pci_create_OF_bus_map(void)
 	struct property* of_prop;
 	struct device_node *dn;
 
-	of_prop = memblock_virt_alloc(sizeof(struct property) + 256, 0);
+	of_prop = memblock_alloc(sizeof(struct property) + 256, 0);
 	dn = of_find_node_by_path("/");
 	if (dn) {
 		memset(of_prop, -1, sizeof(struct property) + 256);
diff --git a/arch/powerpc/lib/alloc.c b/arch/powerpc/lib/alloc.c
index 06796de..bf87d6e 100644
--- a/arch/powerpc/lib/alloc.c
+++ b/arch/powerpc/lib/alloc.c
@@ -14,7 +14,7 @@ void * __ref zalloc_maybe_bootmem(size_t size, gfp_t mask)
 	if (slab_is_available())
 		p = kzalloc(size, mask);
 	else {
-		p = memblock_virt_alloc(size, 0);
+		p = memblock_alloc(size, 0);
 	}
 	return p;
 }
diff --git a/arch/powerpc/mm/mmu_context_nohash.c b/arch/powerpc/mm/mmu_context_nohash.c
index 4d80239..954f198 100644
--- a/arch/powerpc/mm/mmu_context_nohash.c
+++ b/arch/powerpc/mm/mmu_context_nohash.c
@@ -461,10 +461,10 @@ void __init mmu_context_init(void)
 	/*
 	 * Allocate the maps used by context management
 	 */
-	context_map = memblock_virt_alloc(CTX_MAP_SIZE, 0);
-	context_mm = memblock_virt_alloc(sizeof(void *) * (LAST_CONTEXT + 1), 0);
+	context_map = memblock_alloc(CTX_MAP_SIZE, 0);
+	context_mm = memblock_alloc(sizeof(void *) * (LAST_CONTEXT + 1), 0);
 #ifdef CONFIG_SMP
-	stale_map[boot_cpuid] = memblock_virt_alloc(CTX_MAP_SIZE, 0);
+	stale_map[boot_cpuid] = memblock_alloc(CTX_MAP_SIZE, 0);
 
 	cpuhp_setup_state_nocalls(CPUHP_POWERPC_MMU_CTX_PREPARE,
 				  "powerpc/mmu/ctx:prepare",
diff --git a/arch/powerpc/platforms/powermac/nvram.c b/arch/powerpc/platforms/powermac/nvram.c
index 60b03a1..f45b369 100644
--- a/arch/powerpc/platforms/powermac/nvram.c
+++ b/arch/powerpc/platforms/powermac/nvram.c
@@ -513,7 +513,7 @@ static int __init core99_nvram_setup(struct device_node *dp, unsigned long addr)
 		printk(KERN_ERR "nvram: no address\n");
 		return -EINVAL;
 	}
-	nvram_image = memblock_virt_alloc(NVRAM_SIZE, 0);
+	nvram_image = memblock_alloc(NVRAM_SIZE, 0);
 	nvram_data = ioremap(addr, NVRAM_SIZE*2);
 	nvram_naddrs = 1; /* Make sure we get the correct case */
 
diff --git a/arch/powerpc/platforms/powernv/pci-ioda.c b/arch/powerpc/platforms/powernv/pci-ioda.c
index cde7102..23a67b5 100644
--- a/arch/powerpc/platforms/powernv/pci-ioda.c
+++ b/arch/powerpc/platforms/powernv/pci-ioda.c
@@ -3770,7 +3770,7 @@ static void __init pnv_pci_init_ioda_phb(struct device_node *np,
 	phb_id = be64_to_cpup(prop64);
 	pr_debug("  PHB-ID  : 0x%016llx\n", phb_id);
 
-	phb = memblock_virt_alloc(sizeof(*phb), 0);
+	phb = memblock_alloc(sizeof(*phb), 0);
 
 	/* Allocate PCI controller */
 	phb->hose = hose = pcibios_alloc_controller(np);
@@ -3816,7 +3816,7 @@ static void __init pnv_pci_init_ioda_phb(struct device_node *np,
 	else
 		phb->diag_data_size = PNV_PCI_DIAG_BUF_SIZE;
 
-	phb->diag_data = memblock_virt_alloc(phb->diag_data_size, 0);
+	phb->diag_data = memblock_alloc(phb->diag_data_size, 0);
 
 	/* Parse 32-bit and IO ranges (if any) */
 	pci_process_bridge_OF_ranges(hose, np, !hose->global_number);
@@ -3875,7 +3875,7 @@ static void __init pnv_pci_init_ioda_phb(struct device_node *np,
 	}
 	pemap_off = size;
 	size += phb->ioda.total_pe_num * sizeof(struct pnv_ioda_pe);
-	aux = memblock_virt_alloc(size, 0);
+	aux = memblock_alloc(size, 0);
 	phb->ioda.pe_alloc = aux;
 	phb->ioda.m64_segmap = aux + m64map_off;
 	phb->ioda.m32_segmap = aux + m32map_off;
diff --git a/arch/powerpc/platforms/ps3/setup.c b/arch/powerpc/platforms/ps3/setup.c
index 77a3752..1251985 100644
--- a/arch/powerpc/platforms/ps3/setup.c
+++ b/arch/powerpc/platforms/ps3/setup.c
@@ -126,7 +126,7 @@ static void __init prealloc(struct ps3_prealloc *p)
 	if (!p->size)
 		return;
 
-	p->address = memblock_virt_alloc(p->size, p->align);
+	p->address = memblock_alloc(p->size, p->align);
 
 	printk(KERN_INFO "%s: %lu bytes at %p\n", p->name, p->size,
 	       p->address);
diff --git a/arch/powerpc/sysdev/msi_bitmap.c b/arch/powerpc/sysdev/msi_bitmap.c
index e64a411..349a9ff 100644
--- a/arch/powerpc/sysdev/msi_bitmap.c
+++ b/arch/powerpc/sysdev/msi_bitmap.c
@@ -128,7 +128,7 @@ int __ref msi_bitmap_alloc(struct msi_bitmap *bmp, unsigned int irq_count,
 	if (bmp->bitmap_from_slab)
 		bmp->bitmap = kzalloc(size, GFP_KERNEL);
 	else {
-		bmp->bitmap = memblock_virt_alloc(size, 0);
+		bmp->bitmap = memblock_alloc(size, 0);
 		/* the bitmap won't be freed from memblock allocator */
 		kmemleak_not_leak(bmp->bitmap);
 	}
diff --git a/arch/s390/kernel/setup.c b/arch/s390/kernel/setup.c
index 2f2ee43..2e29456 100644
--- a/arch/s390/kernel/setup.c
+++ b/arch/s390/kernel/setup.c
@@ -311,7 +311,7 @@ static void __init setup_lowcore(void)
 	 * Setup lowcore for boot cpu
 	 */
 	BUILD_BUG_ON(sizeof(struct lowcore) != LC_PAGES * PAGE_SIZE);
-	lc = memblock_virt_alloc_low(sizeof(*lc), sizeof(*lc));
+	lc = memblock_alloc_low(sizeof(*lc), sizeof(*lc));
 	lc->restart_psw.mask = PSW_KERNEL_BITS;
 	lc->restart_psw.addr = (unsigned long) restart_int_handler;
 	lc->external_new_psw.mask = PSW_KERNEL_BITS |
@@ -332,10 +332,10 @@ static void __init setup_lowcore(void)
 	lc->kernel_stack = ((unsigned long) &init_thread_union)
 		+ THREAD_SIZE - STACK_FRAME_OVERHEAD - sizeof(struct pt_regs);
 	lc->async_stack = (unsigned long)
-		memblock_virt_alloc(ASYNC_SIZE, ASYNC_SIZE)
+		memblock_alloc(ASYNC_SIZE, ASYNC_SIZE)
 		+ ASYNC_SIZE - STACK_FRAME_OVERHEAD - sizeof(struct pt_regs);
 	lc->panic_stack = (unsigned long)
-		memblock_virt_alloc(PAGE_SIZE, PAGE_SIZE)
+		memblock_alloc(PAGE_SIZE, PAGE_SIZE)
 		+ PAGE_SIZE - STACK_FRAME_OVERHEAD - sizeof(struct pt_regs);
 	lc->current_task = (unsigned long)&init_task;
 	lc->lpp = LPP_MAGIC;
@@ -357,7 +357,7 @@ static void __init setup_lowcore(void)
 	lc->last_update_timer = S390_lowcore.last_update_timer;
 	lc->last_update_clock = S390_lowcore.last_update_clock;
 
-	restart_stack = memblock_virt_alloc(ASYNC_SIZE, ASYNC_SIZE);
+	restart_stack = memblock_alloc(ASYNC_SIZE, ASYNC_SIZE);
 	restart_stack += ASYNC_SIZE;
 
 	/*
@@ -423,7 +423,7 @@ static void __init setup_resources(void)
 	bss_resource.end = (unsigned long) __bss_stop - 1;
 
 	for_each_memblock(memory, reg) {
-		res = memblock_virt_alloc(sizeof(*res), 8);
+		res = memblock_alloc(sizeof(*res), 8);
 		res->flags = IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM;
 
 		res->name = "System RAM";
@@ -437,7 +437,7 @@ static void __init setup_resources(void)
 			    std_res->start > res->end)
 				continue;
 			if (std_res->end > res->end) {
-				sub_res = memblock_virt_alloc(sizeof(*sub_res), 8);
+				sub_res = memblock_alloc(sizeof(*sub_res), 8);
 				*sub_res = *std_res;
 				sub_res->end = res->end;
 				std_res->start = res->end + 1;
diff --git a/arch/s390/kernel/smp.c b/arch/s390/kernel/smp.c
index 2f8f7d7..8f3aafc 100644
--- a/arch/s390/kernel/smp.c
+++ b/arch/s390/kernel/smp.c
@@ -751,7 +751,7 @@ void __init smp_detect_cpus(void)
 	u16 address;
 
 	/* Get CPU information */
-	info = memblock_virt_alloc(sizeof(*info), 8);
+	info = memblock_alloc(sizeof(*info), 8);
 	smp_get_core_info(info, 1);
 	/* Find boot CPU type */
 	if (sclp.has_core_type) {
diff --git a/arch/s390/kernel/topology.c b/arch/s390/kernel/topology.c
index e8184a1..799a918 100644
--- a/arch/s390/kernel/topology.c
+++ b/arch/s390/kernel/topology.c
@@ -519,7 +519,7 @@ static void __init alloc_masks(struct sysinfo_15_1_x *info,
 		nr_masks *= info->mag[TOPOLOGY_NR_MAG - offset - 1 - i];
 	nr_masks = max(nr_masks, 1);
 	for (i = 0; i < nr_masks; i++) {
-		mask->next = memblock_virt_alloc(sizeof(*mask->next), 8);
+		mask->next = memblock_alloc(sizeof(*mask->next), 8);
 		mask = mask->next;
 	}
 }
@@ -537,7 +537,7 @@ void __init topology_init_early(void)
 	}
 	if (!MACHINE_HAS_TOPOLOGY)
 		goto out;
-	tl_info = memblock_virt_alloc(PAGE_SIZE, PAGE_SIZE);
+	tl_info = memblock_alloc(PAGE_SIZE, PAGE_SIZE);
 	info = tl_info;
 	store_topology(info);
 	pr_info("The CPU configuration topology of the machine is: %d %d %d %d %d %d / %d\n",
diff --git a/arch/s390/numa/mode_emu.c b/arch/s390/numa/mode_emu.c
index 83b222c..5a381fc 100644
--- a/arch/s390/numa/mode_emu.c
+++ b/arch/s390/numa/mode_emu.c
@@ -313,7 +313,7 @@ static void __ref create_core_to_node_map(void)
 {
 	int i;
 
-	emu_cores = memblock_virt_alloc(sizeof(*emu_cores), 8);
+	emu_cores = memblock_alloc(sizeof(*emu_cores), 8);
 	for (i = 0; i < ARRAY_SIZE(emu_cores->to_node_id); i++)
 		emu_cores->to_node_id[i] = NODE_ID_FREE;
 }
diff --git a/arch/s390/numa/toptree.c b/arch/s390/numa/toptree.c
index 21d1e8a..7f61cc3 100644
--- a/arch/s390/numa/toptree.c
+++ b/arch/s390/numa/toptree.c
@@ -34,7 +34,7 @@ struct toptree __ref *toptree_alloc(int level, int id)
 	if (slab_is_available())
 		res = kzalloc(sizeof(*res), GFP_KERNEL);
 	else
-		res = memblock_virt_alloc(sizeof(*res), 8);
+		res = memblock_alloc(sizeof(*res), 8);
 	if (!res)
 		return res;
 
diff --git a/arch/x86/mm/kasan_init_64.c b/arch/x86/mm/kasan_init_64.c
index e3e7752..77b857c 100644
--- a/arch/x86/mm/kasan_init_64.c
+++ b/arch/x86/mm/kasan_init_64.c
@@ -28,10 +28,10 @@ static p4d_t tmp_p4d_table[MAX_PTRS_PER_P4D] __initdata __aligned(PAGE_SIZE);
 static __init void *early_alloc(size_t size, int nid, bool panic)
 {
 	if (panic)
-		return memblock_virt_alloc_try_nid(size, size,
+		return memblock_alloc_try_nid(size, size,
 			__pa(MAX_DMA_ADDRESS), BOOTMEM_ALLOC_ACCESSIBLE, nid);
 	else
-		return memblock_virt_alloc_try_nid_nopanic(size, size,
+		return memblock_alloc_try_nid_nopanic(size, size,
 			__pa(MAX_DMA_ADDRESS), BOOTMEM_ALLOC_ACCESSIBLE, nid);
 }
 
diff --git a/arch/xtensa/mm/kasan_init.c b/arch/xtensa/mm/kasan_init.c
index 6b532b6..1a30a25 100644
--- a/arch/xtensa/mm/kasan_init.c
+++ b/arch/xtensa/mm/kasan_init.c
@@ -43,7 +43,7 @@ static void __init populate(void *start, void *end)
 	unsigned long vaddr = (unsigned long)start;
 	pgd_t *pgd = pgd_offset_k(vaddr);
 	pmd_t *pmd = pmd_offset(pgd, vaddr);
-	pte_t *pte = memblock_virt_alloc(n_pages * sizeof(pte_t), PAGE_SIZE);
+	pte_t *pte = memblock_alloc(n_pages * sizeof(pte_t), PAGE_SIZE);
 
 	pr_debug("%s: %p - %p\n", __func__, start, end);
 
diff --git a/drivers/clk/ti/clk.c b/drivers/clk/ti/clk.c
index 33001a7..a0136ed 100644
--- a/drivers/clk/ti/clk.c
+++ b/drivers/clk/ti/clk.c
@@ -347,7 +347,7 @@ void __init omap2_clk_legacy_provider_init(int index, void __iomem *mem)
 {
 	struct clk_iomap *io;
 
-	io = memblock_virt_alloc(sizeof(*io), 0);
+	io = memblock_alloc(sizeof(*io), 0);
 
 	io->mem = mem;
 
diff --git a/drivers/firmware/memmap.c b/drivers/firmware/memmap.c
index 5de3ed2..03cead6 100644
--- a/drivers/firmware/memmap.c
+++ b/drivers/firmware/memmap.c
@@ -333,7 +333,7 @@ int __init firmware_map_add_early(u64 start, u64 end, const char *type)
 {
 	struct firmware_map_entry *entry;
 
-	entry = memblock_virt_alloc(sizeof(struct firmware_map_entry), 0);
+	entry = memblock_alloc(sizeof(struct firmware_map_entry), 0);
 	if (WARN_ON(!entry))
 		return -ENOMEM;
 
diff --git a/drivers/of/fdt.c b/drivers/of/fdt.c
index bd841bb..34dd878 100644
--- a/drivers/of/fdt.c
+++ b/drivers/of/fdt.c
@@ -1198,7 +1198,7 @@ int __init __weak early_init_dt_reserve_memory_arch(phys_addr_t base,
 
 static void * __init early_init_dt_alloc_memory_arch(u64 size, u64 align)
 {
-	return memblock_virt_alloc(size, align);
+	return memblock_alloc(size, align);
 }
 
 bool __init early_init_dt_verify(void *params)
diff --git a/drivers/of/unittest.c b/drivers/of/unittest.c
index 35b7886..07c9217 100644
--- a/drivers/of/unittest.c
+++ b/drivers/of/unittest.c
@@ -2182,7 +2182,7 @@ static struct device_node *overlay_base_root;
 
 static void * __init dt_alloc_memory(u64 size, u64 align)
 {
-	return memblock_virt_alloc(size, align);
+	return memblock_alloc(size, align);
 }
 
 /*
diff --git a/include/linux/bootmem.h b/include/linux/bootmem.h
index b74bafd1..7d91f0f 100644
--- a/include/linux/bootmem.h
+++ b/include/linux/bootmem.h
@@ -95,78 +95,78 @@ extern void *__alloc_bootmem_low(unsigned long size,
 #define BOOTMEM_ALLOC_ANYWHERE		(~(phys_addr_t)0)
 
 /* FIXME: Move to memblock.h at a point where we remove nobootmem.c */
-void *memblock_virt_alloc_try_nid_raw(phys_addr_t size, phys_addr_t align,
+void *memblock_alloc_try_nid_raw(phys_addr_t size, phys_addr_t align,
 				      phys_addr_t min_addr,
 				      phys_addr_t max_addr, int nid);
-void *memblock_virt_alloc_try_nid_nopanic(phys_addr_t size,
+void *memblock_alloc_try_nid_nopanic(phys_addr_t size,
 		phys_addr_t align, phys_addr_t min_addr,
 		phys_addr_t max_addr, int nid);
-void *memblock_virt_alloc_try_nid(phys_addr_t size, phys_addr_t align,
+void *memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align,
 		phys_addr_t min_addr, phys_addr_t max_addr, int nid);
 void __memblock_free_early(phys_addr_t base, phys_addr_t size);
 void __memblock_free_late(phys_addr_t base, phys_addr_t size);
 
-static inline void * __init memblock_virt_alloc(
+static inline void * __init memblock_alloc(
 					phys_addr_t size,  phys_addr_t align)
 {
-	return memblock_virt_alloc_try_nid(size, align, BOOTMEM_LOW_LIMIT,
+	return memblock_alloc_try_nid(size, align, BOOTMEM_LOW_LIMIT,
 					    BOOTMEM_ALLOC_ACCESSIBLE,
 					    NUMA_NO_NODE);
 }
 
-static inline void * __init memblock_virt_alloc_raw(
+static inline void * __init memblock_alloc_raw(
 					phys_addr_t size,  phys_addr_t align)
 {
-	return memblock_virt_alloc_try_nid_raw(size, align, BOOTMEM_LOW_LIMIT,
+	return memblock_alloc_try_nid_raw(size, align, BOOTMEM_LOW_LIMIT,
 					    BOOTMEM_ALLOC_ACCESSIBLE,
 					    NUMA_NO_NODE);
 }
 
-static inline void * __init memblock_virt_alloc_nopanic(
+static inline void * __init memblock_alloc_nopanic(
 					phys_addr_t size, phys_addr_t align)
 {
-	return memblock_virt_alloc_try_nid_nopanic(size, align,
+	return memblock_alloc_try_nid_nopanic(size, align,
 						    BOOTMEM_LOW_LIMIT,
 						    BOOTMEM_ALLOC_ACCESSIBLE,
 						    NUMA_NO_NODE);
 }
 
-static inline void * __init memblock_virt_alloc_low(
+static inline void * __init memblock_alloc_low(
 					phys_addr_t size, phys_addr_t align)
 {
-	return memblock_virt_alloc_try_nid(size, align,
+	return memblock_alloc_try_nid(size, align,
 						   BOOTMEM_LOW_LIMIT,
 						   ARCH_LOW_ADDRESS_LIMIT,
 						   NUMA_NO_NODE);
 }
-static inline void * __init memblock_virt_alloc_low_nopanic(
+static inline void * __init memblock_alloc_low_nopanic(
 					phys_addr_t size, phys_addr_t align)
 {
-	return memblock_virt_alloc_try_nid_nopanic(size, align,
+	return memblock_alloc_try_nid_nopanic(size, align,
 						   BOOTMEM_LOW_LIMIT,
 						   ARCH_LOW_ADDRESS_LIMIT,
 						   NUMA_NO_NODE);
 }
 
-static inline void * __init memblock_virt_alloc_from_nopanic(
+static inline void * __init memblock_alloc_from_nopanic(
 		phys_addr_t size, phys_addr_t align, phys_addr_t min_addr)
 {
-	return memblock_virt_alloc_try_nid_nopanic(size, align, min_addr,
+	return memblock_alloc_try_nid_nopanic(size, align, min_addr,
 						    BOOTMEM_ALLOC_ACCESSIBLE,
 						    NUMA_NO_NODE);
 }
 
-static inline void * __init memblock_virt_alloc_node(
+static inline void * __init memblock_alloc_node(
 						phys_addr_t size, int nid)
 {
-	return memblock_virt_alloc_try_nid(size, 0, BOOTMEM_LOW_LIMIT,
+	return memblock_alloc_try_nid(size, 0, BOOTMEM_LOW_LIMIT,
 					    BOOTMEM_ALLOC_ACCESSIBLE, nid);
 }
 
-static inline void * __init memblock_virt_alloc_node_nopanic(
+static inline void * __init memblock_alloc_node_nopanic(
 						phys_addr_t size, int nid)
 {
-	return memblock_virt_alloc_try_nid_nopanic(size, 0, BOOTMEM_LOW_LIMIT,
+	return memblock_alloc_try_nid_nopanic(size, 0, BOOTMEM_LOW_LIMIT,
 						    BOOTMEM_ALLOC_ACCESSIBLE,
 						    nid);
 }
diff --git a/init/main.c b/init/main.c
index 18f8f01..d0b92bd 100644
--- a/init/main.c
+++ b/init/main.c
@@ -375,10 +375,10 @@ static inline void smp_prepare_cpus(unsigned int maxcpus) { }
 static void __init setup_command_line(char *command_line)
 {
 	saved_command_line =
-		memblock_virt_alloc(strlen(boot_command_line) + 1, 0);
+		memblock_alloc(strlen(boot_command_line) + 1, 0);
 	initcall_command_line =
-		memblock_virt_alloc(strlen(boot_command_line) + 1, 0);
-	static_command_line = memblock_virt_alloc(strlen(command_line) + 1, 0);
+		memblock_alloc(strlen(boot_command_line) + 1, 0);
+	static_command_line = memblock_alloc(strlen(command_line) + 1, 0);
 	strcpy(saved_command_line, boot_command_line);
 	strcpy(static_command_line, command_line);
 }
diff --git a/kernel/dma/swiotlb.c b/kernel/dma/swiotlb.c
index 4f8a6db..d9fd062 100644
--- a/kernel/dma/swiotlb.c
+++ b/kernel/dma/swiotlb.c
@@ -215,7 +215,7 @@ int __init swiotlb_init_with_tbl(char *tlb, unsigned long nslabs, int verbose)
 	/*
 	 * Get the overflow emergency buffer
 	 */
-	v_overflow_buffer = memblock_virt_alloc_low_nopanic(
+	v_overflow_buffer = memblock_alloc_low_nopanic(
 						PAGE_ALIGN(io_tlb_overflow),
 						PAGE_SIZE);
 	if (!v_overflow_buffer)
@@ -228,10 +228,10 @@ int __init swiotlb_init_with_tbl(char *tlb, unsigned long nslabs, int verbose)
 	 * to find contiguous free memory regions of size up to IO_TLB_SEGSIZE
 	 * between io_tlb_start and io_tlb_end.
 	 */
-	io_tlb_list = memblock_virt_alloc(
+	io_tlb_list = memblock_alloc(
 				PAGE_ALIGN(io_tlb_nslabs * sizeof(int)),
 				PAGE_SIZE);
-	io_tlb_orig_addr = memblock_virt_alloc(
+	io_tlb_orig_addr = memblock_alloc(
 				PAGE_ALIGN(io_tlb_nslabs * sizeof(phys_addr_t)),
 				PAGE_SIZE);
 	for (i = 0; i < io_tlb_nslabs; i++) {
@@ -266,7 +266,7 @@ swiotlb_init(int verbose)
 	bytes = io_tlb_nslabs << IO_TLB_SHIFT;
 
 	/* Get IO TLB memory from the low pages */
-	vstart = memblock_virt_alloc_low_nopanic(PAGE_ALIGN(bytes), PAGE_SIZE);
+	vstart = memblock_alloc_low_nopanic(PAGE_ALIGN(bytes), PAGE_SIZE);
 	if (vstart && !swiotlb_init_with_tbl(vstart, io_tlb_nslabs, verbose))
 		return;
 
diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
index 3d37c27..34116a6 100644
--- a/kernel/power/snapshot.c
+++ b/kernel/power/snapshot.c
@@ -963,7 +963,7 @@ void __init __register_nosave_region(unsigned long start_pfn,
 		BUG_ON(!region);
 	} else {
 		/* This allocation cannot fail */
-		region = memblock_virt_alloc(sizeof(struct nosave_region), 0);
+		region = memblock_alloc(sizeof(struct nosave_region), 0);
 	}
 	region->start_pfn = start_pfn;
 	region->end_pfn = end_pfn;
diff --git a/kernel/printk/printk.c b/kernel/printk/printk.c
index 9bf5404..3efcbe518 100644
--- a/kernel/printk/printk.c
+++ b/kernel/printk/printk.c
@@ -1106,9 +1106,9 @@ void __init setup_log_buf(int early)
 
 	if (early) {
 		new_log_buf =
-			memblock_virt_alloc(new_log_buf_len, LOG_ALIGN);
+			memblock_alloc(new_log_buf_len, LOG_ALIGN);
 	} else {
-		new_log_buf = memblock_virt_alloc_nopanic(new_log_buf_len,
+		new_log_buf = memblock_alloc_nopanic(new_log_buf_len,
 							  LOG_ALIGN);
 	}
 
diff --git a/lib/cpumask.c b/lib/cpumask.c
index beca624..1405cb2 100644
--- a/lib/cpumask.c
+++ b/lib/cpumask.c
@@ -163,7 +163,7 @@ EXPORT_SYMBOL(zalloc_cpumask_var);
  */
 void __init alloc_bootmem_cpumask_var(cpumask_var_t *mask)
 {
-	*mask = memblock_virt_alloc(cpumask_size(), 0);
+	*mask = memblock_alloc(cpumask_size(), 0);
 }
 
 /**
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 5c390f5..3b63370 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2100,7 +2100,7 @@ int __alloc_bootmem_huge_page(struct hstate *h)
 	for_each_node_mask_to_alloc(h, nr_nodes, node, &node_states[N_MEMORY]) {
 		void *addr;
 
-		addr = memblock_virt_alloc_try_nid_raw(
+		addr = memblock_alloc_try_nid_raw(
 				huge_page_size(h), huge_page_size(h),
 				0, BOOTMEM_ALLOC_ACCESSIBLE, node);
 		if (addr) {
diff --git a/mm/kasan/kasan_init.c b/mm/kasan/kasan_init.c
index 7a2a2f1..24d734b 100644
--- a/mm/kasan/kasan_init.c
+++ b/mm/kasan/kasan_init.c
@@ -83,7 +83,7 @@ static inline bool kasan_zero_page_entry(pte_t pte)
 
 static __init void *early_alloc(size_t size, int node)
 {
-	return memblock_virt_alloc_try_nid(size, size, __pa(MAX_DMA_ADDRESS),
+	return memblock_alloc_try_nid(size, size, __pa(MAX_DMA_ADDRESS),
 					BOOTMEM_ALLOC_ACCESSIBLE, node);
 }
 
diff --git a/mm/memblock.c b/mm/memblock.c
index f8b6b79..3a21476 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1370,7 +1370,7 @@ phys_addr_t __init memblock_phys_alloc_try_nid(phys_addr_t size, phys_addr_t ali
 }
 
 /**
- * memblock_virt_alloc_internal - allocate boot memory block
+ * memblock_alloc_internal - allocate boot memory block
  * @size: size of memory block to be allocated in bytes
  * @align: alignment of the region and block's size
  * @min_addr: the lower bound of the memory region to allocate (phys address)
@@ -1396,7 +1396,7 @@ phys_addr_t __init memblock_phys_alloc_try_nid(phys_addr_t size, phys_addr_t ali
  * Return:
  * Virtual address of allocated memory block on success, NULL on failure.
  */
-static void * __init memblock_virt_alloc_internal(
+static void * __init memblock_alloc_internal(
 				phys_addr_t size, phys_addr_t align,
 				phys_addr_t min_addr, phys_addr_t max_addr,
 				int nid)
@@ -1463,7 +1463,7 @@ static void * __init memblock_virt_alloc_internal(
 }
 
 /**
- * memblock_virt_alloc_try_nid_raw - allocate boot memory block without zeroing
+ * memblock_alloc_try_nid_raw - allocate boot memory block without zeroing
  * memory and without panicking
  * @size: size of memory block to be allocated in bytes
  * @align: alignment of the region and block's size
@@ -1481,7 +1481,7 @@ static void * __init memblock_virt_alloc_internal(
  * Return:
  * Virtual address of allocated memory block on success, NULL on failure.
  */
-void * __init memblock_virt_alloc_try_nid_raw(
+void * __init memblock_alloc_try_nid_raw(
 			phys_addr_t size, phys_addr_t align,
 			phys_addr_t min_addr, phys_addr_t max_addr,
 			int nid)
@@ -1492,7 +1492,7 @@ void * __init memblock_virt_alloc_try_nid_raw(
 		     __func__, (u64)size, (u64)align, nid, &min_addr,
 		     &max_addr, (void *)_RET_IP_);
 
-	ptr = memblock_virt_alloc_internal(size, align,
+	ptr = memblock_alloc_internal(size, align,
 					   min_addr, max_addr, nid);
 #ifdef CONFIG_DEBUG_VM
 	if (ptr && size > 0)
@@ -1502,7 +1502,7 @@ void * __init memblock_virt_alloc_try_nid_raw(
 }
 
 /**
- * memblock_virt_alloc_try_nid_nopanic - allocate boot memory block
+ * memblock_alloc_try_nid_nopanic - allocate boot memory block
  * @size: size of memory block to be allocated in bytes
  * @align: alignment of the region and block's size
  * @min_addr: the lower bound of the memory region from where the allocation
@@ -1518,7 +1518,7 @@ void * __init memblock_virt_alloc_try_nid_raw(
  * Return:
  * Virtual address of allocated memory block on success, NULL on failure.
  */
-void * __init memblock_virt_alloc_try_nid_nopanic(
+void * __init memblock_alloc_try_nid_nopanic(
 				phys_addr_t size, phys_addr_t align,
 				phys_addr_t min_addr, phys_addr_t max_addr,
 				int nid)
@@ -1529,7 +1529,7 @@ void * __init memblock_virt_alloc_try_nid_nopanic(
 		     __func__, (u64)size, (u64)align, nid, &min_addr,
 		     &max_addr, (void *)_RET_IP_);
 
-	ptr = memblock_virt_alloc_internal(size, align,
+	ptr = memblock_alloc_internal(size, align,
 					   min_addr, max_addr, nid);
 	if (ptr)
 		memset(ptr, 0, size);
@@ -1537,7 +1537,7 @@ void * __init memblock_virt_alloc_try_nid_nopanic(
 }
 
 /**
- * memblock_virt_alloc_try_nid - allocate boot memory block with panicking
+ * memblock_alloc_try_nid - allocate boot memory block with panicking
  * @size: size of memory block to be allocated in bytes
  * @align: alignment of the region and block's size
  * @min_addr: the lower bound of the memory region from where the allocation
@@ -1547,14 +1547,14 @@ void * __init memblock_virt_alloc_try_nid_nopanic(
  *	      allocate only from memory limited by memblock.current_limit value
  * @nid: nid of the free area to find, %NUMA_NO_NODE for any node
  *
- * Public panicking version of memblock_virt_alloc_try_nid_nopanic()
+ * Public panicking version of memblock_alloc_try_nid_nopanic()
  * which provides debug information (including caller info), if enabled,
  * and panics if the request can not be satisfied.
  *
  * Return:
  * Virtual address of allocated memory block on success, NULL on failure.
  */
-void * __init memblock_virt_alloc_try_nid(
+void * __init memblock_alloc_try_nid(
 			phys_addr_t size, phys_addr_t align,
 			phys_addr_t min_addr, phys_addr_t max_addr,
 			int nid)
@@ -1564,7 +1564,7 @@ void * __init memblock_virt_alloc_try_nid(
 	memblock_dbg("%s: %llu bytes align=0x%llx nid=%d from=%pa max_addr=%pa %pF\n",
 		     __func__, (u64)size, (u64)align, nid, &min_addr,
 		     &max_addr, (void *)_RET_IP_);
-	ptr = memblock_virt_alloc_internal(size, align,
+	ptr = memblock_alloc_internal(size, align,
 					   min_addr, max_addr, nid);
 	if (ptr) {
 		memset(ptr, 0, size);
@@ -1581,7 +1581,7 @@ void * __init memblock_virt_alloc_try_nid(
  * @base: phys starting address of the  boot memory block
  * @size: size of the boot memory block in bytes
  *
- * Free boot memory block previously allocated by memblock_virt_alloc_xx() API.
+ * Free boot memory block previously allocated by memblock_alloc_xx() API.
  * The freeing memory will not be released to the buddy allocator.
  */
 void __init __memblock_free_early(phys_addr_t base, phys_addr_t size)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 3f3094d..7658a6f 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -6121,7 +6121,7 @@ static void __ref setup_usemap(struct pglist_data *pgdat,
 	zone->pageblock_flags = NULL;
 	if (usemapsize)
 		zone->pageblock_flags =
-			memblock_virt_alloc_node_nopanic(usemapsize,
+			memblock_alloc_node_nopanic(usemapsize,
 							 pgdat->node_id);
 }
 #else
@@ -6363,7 +6363,7 @@ static void __ref alloc_node_mem_map(struct pglist_data *pgdat)
 		end = pgdat_end_pfn(pgdat);
 		end = ALIGN(end, MAX_ORDER_NR_PAGES);
 		size =  (end - start) * sizeof(struct page);
-		map = memblock_virt_alloc_node_nopanic(size, pgdat->node_id);
+		map = memblock_alloc_node_nopanic(size, pgdat->node_id);
 		pgdat->node_mem_map = map + offset;
 	}
 	pr_debug("%s: node %d, pgdat %08lx, node_mem_map %08lx\n",
@@ -7616,9 +7616,9 @@ void *__init alloc_large_system_hash(const char *tablename,
 		size = bucketsize << log2qty;
 		if (flags & HASH_EARLY) {
 			if (flags & HASH_ZERO)
-				table = memblock_virt_alloc_nopanic(size, 0);
+				table = memblock_alloc_nopanic(size, 0);
 			else
-				table = memblock_virt_alloc_raw(size, 0);
+				table = memblock_alloc_raw(size, 0);
 		} else if (hashdist) {
 			table = __vmalloc(size, gfp_flags, PAGE_KERNEL);
 		} else {
diff --git a/mm/page_ext.c b/mm/page_ext.c
index a9826da..e77c0f0 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -161,7 +161,7 @@ static int __init alloc_node_page_ext(int nid)
 
 	table_size = get_entry_size() * nr_pages;
 
-	base = memblock_virt_alloc_try_nid_nopanic(
+	base = memblock_alloc_try_nid_nopanic(
 			table_size, PAGE_SIZE, __pa(MAX_DMA_ADDRESS),
 			BOOTMEM_ALLOC_ACCESSIBLE, nid);
 	if (!base)
diff --git a/mm/percpu.c b/mm/percpu.c
index a749d4d..86bb9f6 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -1101,7 +1101,7 @@ static struct pcpu_chunk * __init pcpu_alloc_first_chunk(unsigned long tmp_addr,
 	region_size = ALIGN(start_offset + map_size, lcm_align);
 
 	/* allocate chunk */
-	chunk = memblock_virt_alloc(sizeof(struct pcpu_chunk) +
+	chunk = memblock_alloc(sizeof(struct pcpu_chunk) +
 				    BITS_TO_LONGS(region_size >> PAGE_SHIFT),
 				    0);
 
@@ -1114,11 +1114,11 @@ static struct pcpu_chunk * __init pcpu_alloc_first_chunk(unsigned long tmp_addr,
 	chunk->nr_pages = region_size >> PAGE_SHIFT;
 	region_bits = pcpu_chunk_map_bits(chunk);
 
-	chunk->alloc_map = memblock_virt_alloc(BITS_TO_LONGS(region_bits) *
+	chunk->alloc_map = memblock_alloc(BITS_TO_LONGS(region_bits) *
 					       sizeof(chunk->alloc_map[0]), 0);
-	chunk->bound_map = memblock_virt_alloc(BITS_TO_LONGS(region_bits + 1) *
+	chunk->bound_map = memblock_alloc(BITS_TO_LONGS(region_bits + 1) *
 					       sizeof(chunk->bound_map[0]), 0);
-	chunk->md_blocks = memblock_virt_alloc(pcpu_chunk_nr_blocks(chunk) *
+	chunk->md_blocks = memblock_alloc(pcpu_chunk_nr_blocks(chunk) *
 					       sizeof(chunk->md_blocks[0]), 0);
 	pcpu_init_md_blocks(chunk);
 
@@ -1887,7 +1887,7 @@ struct pcpu_alloc_info * __init pcpu_alloc_alloc_info(int nr_groups,
 			  __alignof__(ai->groups[0].cpu_map[0]));
 	ai_size = base_size + nr_units * sizeof(ai->groups[0].cpu_map[0]);
 
-	ptr = memblock_virt_alloc_nopanic(PFN_ALIGN(ai_size), PAGE_SIZE);
+	ptr = memblock_alloc_nopanic(PFN_ALIGN(ai_size), PAGE_SIZE);
 	if (!ptr)
 		return NULL;
 	ai = ptr;
@@ -2074,12 +2074,12 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	PCPU_SETUP_BUG_ON(pcpu_verify_alloc_info(ai) < 0);
 
 	/* process group information and build config tables accordingly */
-	group_offsets = memblock_virt_alloc(ai->nr_groups *
+	group_offsets = memblock_alloc(ai->nr_groups *
 					     sizeof(group_offsets[0]), 0);
-	group_sizes = memblock_virt_alloc(ai->nr_groups *
+	group_sizes = memblock_alloc(ai->nr_groups *
 					   sizeof(group_sizes[0]), 0);
-	unit_map = memblock_virt_alloc(nr_cpu_ids * sizeof(unit_map[0]), 0);
-	unit_off = memblock_virt_alloc(nr_cpu_ids * sizeof(unit_off[0]), 0);
+	unit_map = memblock_alloc(nr_cpu_ids * sizeof(unit_map[0]), 0);
+	unit_off = memblock_alloc(nr_cpu_ids * sizeof(unit_off[0]), 0);
 
 	for (cpu = 0; cpu < nr_cpu_ids; cpu++)
 		unit_map[cpu] = UINT_MAX;
@@ -2143,7 +2143,7 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	 * empty chunks.
 	 */
 	pcpu_nr_slots = __pcpu_size_to_slot(pcpu_unit_size) + 2;
-	pcpu_slot = memblock_virt_alloc(
+	pcpu_slot = memblock_alloc(
 			pcpu_nr_slots * sizeof(pcpu_slot[0]), 0);
 	for (i = 0; i < pcpu_nr_slots; i++)
 		INIT_LIST_HEAD(&pcpu_slot[i]);
@@ -2457,7 +2457,7 @@ int __init pcpu_embed_first_chunk(size_t reserved_size, size_t dyn_size,
 	size_sum = ai->static_size + ai->reserved_size + ai->dyn_size;
 	areas_size = PFN_ALIGN(ai->nr_groups * sizeof(void *));
 
-	areas = memblock_virt_alloc_nopanic(areas_size, 0);
+	areas = memblock_alloc_nopanic(areas_size, 0);
 	if (!areas) {
 		rc = -ENOMEM;
 		goto out_free;
@@ -2598,7 +2598,7 @@ int __init pcpu_page_first_chunk(size_t reserved_size,
 	/* unaligned allocations can't be freed, round up to page size */
 	pages_size = PFN_ALIGN(unit_pages * num_possible_cpus() *
 			       sizeof(pages[0]));
-	pages = memblock_virt_alloc(pages_size, 0);
+	pages = memblock_alloc(pages_size, 0);
 
 	/* allocate pages */
 	j = 0;
@@ -2687,7 +2687,7 @@ EXPORT_SYMBOL(__per_cpu_offset);
 static void * __init pcpu_dfl_fc_alloc(unsigned int cpu, size_t size,
 				       size_t align)
 {
-	return  memblock_virt_alloc_from_nopanic(
+	return  memblock_alloc_from_nopanic(
 			size, align, __pa(MAX_DMA_ADDRESS));
 }
 
@@ -2736,7 +2736,7 @@ void __init setup_per_cpu_areas(void)
 	void *fc;
 
 	ai = pcpu_alloc_alloc_info(1, 1);
-	fc = memblock_virt_alloc_from_nopanic(unit_size,
+	fc = memblock_alloc_from_nopanic(unit_size,
 					      PAGE_SIZE,
 					      __pa(MAX_DMA_ADDRESS));
 	if (!ai || !fc)
diff --git a/mm/sparse-vmemmap.c b/mm/sparse-vmemmap.c
index 8301293..91c2c3d 100644
--- a/mm/sparse-vmemmap.c
+++ b/mm/sparse-vmemmap.c
@@ -42,7 +42,7 @@ static void * __ref __earlyonly_bootmem_alloc(int node,
 				unsigned long align,
 				unsigned long goal)
 {
-	return memblock_virt_alloc_try_nid_raw(size, align, goal,
+	return memblock_alloc_try_nid_raw(size, align, goal,
 					       BOOTMEM_ALLOC_ACCESSIBLE, node);
 }
 
diff --git a/mm/sparse.c b/mm/sparse.c
index 10b07ee..04e97af 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -68,7 +68,7 @@ static noinline struct mem_section __ref *sparse_index_alloc(int nid)
 	if (slab_is_available())
 		section = kzalloc_node(array_size, GFP_KERNEL, nid);
 	else
-		section = memblock_virt_alloc_node(array_size, nid);
+		section = memblock_alloc_node(array_size, nid);
 
 	return section;
 }
@@ -216,7 +216,7 @@ void __init memory_present(int nid, unsigned long start, unsigned long end)
 
 		size = sizeof(struct mem_section*) * NR_SECTION_ROOTS;
 		align = 1 << (INTERNODE_CACHE_SHIFT);
-		mem_section = memblock_virt_alloc(size, align);
+		mem_section = memblock_alloc(size, align);
 	}
 #endif
 
@@ -306,7 +306,7 @@ sparse_early_usemaps_alloc_pgdat_section(struct pglist_data *pgdat,
 	limit = goal + (1UL << PA_SECTION_SHIFT);
 	nid = early_pfn_to_nid(goal >> PAGE_SHIFT);
 again:
-	p = memblock_virt_alloc_try_nid_nopanic(size,
+	p = memblock_alloc_try_nid_nopanic(size,
 						SMP_CACHE_BYTES, goal, limit,
 						nid);
 	if (!p && limit) {
@@ -362,7 +362,7 @@ static unsigned long * __init
 sparse_early_usemaps_alloc_pgdat_section(struct pglist_data *pgdat,
 					 unsigned long size)
 {
-	return memblock_virt_alloc_node_nopanic(size, pgdat->node_id);
+	return memblock_alloc_node_nopanic(size, pgdat->node_id);
 }
 
 static void __init check_usemap_section_nr(int nid, unsigned long *usemap)
@@ -391,7 +391,7 @@ struct page __init *sparse_mem_map_populate(unsigned long pnum, int nid,
 	if (map)
 		return map;
 
-	map = memblock_virt_alloc_try_nid(size,
+	map = memblock_alloc_try_nid(size,
 					  PAGE_SIZE, __pa(MAX_DMA_ADDRESS),
 					  BOOTMEM_ALLOC_ACCESSIBLE, nid);
 	return map;
@@ -405,7 +405,7 @@ static void __init sparse_buffer_init(unsigned long size, int nid)
 {
 	WARN_ON(sparsemap_buf);	/* forgot to call sparse_buffer_fini()? */
 	sparsemap_buf =
-		memblock_virt_alloc_try_nid_raw(size, PAGE_SIZE,
+		memblock_alloc_try_nid_raw(size, PAGE_SIZE,
 						__pa(MAX_DMA_ADDRESS),
 						BOOTMEM_ALLOC_ACCESSIBLE, nid);
 	sparsemap_buf_end = sparsemap_buf + size;
-- 
2.7.4
