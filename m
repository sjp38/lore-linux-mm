Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id CCFE76B0038
	for <linux-mm@kvack.org>; Tue, 27 Aug 2013 05:39:13 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 02/11] memblock: Rename memblock_set_current_limit() to memblock_set_current_limit_high().
Date: Tue, 27 Aug 2013 17:37:39 +0800
Message-Id: <1377596268-31552-3-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1377596268-31552-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1377596268-31552-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Since we renamed memblock.current_limit to current_limit_high, we also
rename memblock_set_current_limit() to memblock_set_current_limit_high().

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
---
 arch/arm/mm/mmu.c               |    2 +-
 arch/arm64/mm/mmu.c             |    4 ++--
 arch/microblaze/mm/init.c       |    2 +-
 arch/powerpc/mm/40x_mmu.c       |    4 ++--
 arch/powerpc/mm/44x_mmu.c       |    2 +-
 arch/powerpc/mm/fsl_booke_mmu.c |    4 ++--
 arch/powerpc/mm/hash_utils_64.c |    4 ++--
 arch/powerpc/mm/init_32.c       |    4 ++--
 arch/powerpc/mm/ppc_mmu_32.c    |    4 ++--
 arch/powerpc/mm/tlb_nohash.c    |    4 ++--
 arch/unicore32/mm/mmu.c         |    2 +-
 arch/x86/kernel/setup.c         |    4 ++--
 include/linux/memblock.h        |    8 ++++----
 mm/memblock.c                   |    2 +-
 14 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/arch/arm/mm/mmu.c b/arch/arm/mm/mmu.c
index 53cdbd3..121565e 100644
--- a/arch/arm/mm/mmu.c
+++ b/arch/arm/mm/mmu.c
@@ -1114,7 +1114,7 @@ void __init sanity_check_meminfo(void)
 	if (!memblock_limit)
 		memblock_limit = arm_lowmem_limit;
 
-	memblock_set_current_limit(memblock_limit);
+	memblock_set_current_limit_high(memblock_limit);
 }
 
 static inline void prepare_page_table(void)
diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index a8d1059..7f27451 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -305,7 +305,7 @@ static void __init map_mem(void)
 	 * The initial direct kernel mapping, located at swapper_pg_dir,
 	 * gives us PGDIR_SIZE memory starting from PHYS_OFFSET (aligned).
 	 */
-	memblock_set_current_limit((PHYS_OFFSET & PGDIR_MASK) + PGDIR_SIZE);
+	memblock_set_current_limit_high((PHYS_OFFSET & PGDIR_MASK) + PGDIR_SIZE);
 
 	/* map all the memory banks */
 	for_each_memblock(memory, reg) {
@@ -319,7 +319,7 @@ static void __init map_mem(void)
 	}
 
 	/* Limit no longer required. */
-	memblock_set_current_limit(MEMBLOCK_ALLOC_ANYWHERE);
+	memblock_set_current_limit_high(MEMBLOCK_ALLOC_ANYWHERE);
 }
 
 /*
diff --git a/arch/microblaze/mm/init.c b/arch/microblaze/mm/init.c
index 74c7bcc..554b61d 100644
--- a/arch/microblaze/mm/init.c
+++ b/arch/microblaze/mm/init.c
@@ -391,7 +391,7 @@ asmlinkage void __init mmu_init(void)
 	/* Shortly after that, the entire linear mapping will be available */
 	/* This will also cause that unflatten device tree will be allocated
 	 * inside 768MB limit */
-	memblock_set_current_limit(memory_start + lowmem_size - 1);
+	memblock_set_current_limit_high(memory_start + lowmem_size - 1);
 }
 
 /* This is only called until mem_init is done. */
diff --git a/arch/powerpc/mm/40x_mmu.c b/arch/powerpc/mm/40x_mmu.c
index 5810967..9ce26d3 100644
--- a/arch/powerpc/mm/40x_mmu.c
+++ b/arch/powerpc/mm/40x_mmu.c
@@ -141,7 +141,7 @@ unsigned long __init mmu_mapin_ram(unsigned long top)
 	 * coverage with normal-sized pages (or other reasons) do not
 	 * attempt to allocate outside the allowed range.
 	 */
-	memblock_set_current_limit(mapped);
+	memblock_set_current_limit_high(mapped);
 
 	return mapped;
 }
@@ -155,5 +155,5 @@ void setup_initial_memory_limit(phys_addr_t first_memblock_base,
 	BUG_ON(first_memblock_base != 0);
 
 	/* 40x can only access 16MB at the moment (see head_40x.S) */
-	memblock_set_current_limit(min_t(u64, first_memblock_size, 0x00800000));
+	memblock_set_current_limit_high(min_t(u64, first_memblock_size, 0x00800000));
 }
diff --git a/arch/powerpc/mm/44x_mmu.c b/arch/powerpc/mm/44x_mmu.c
index 82b1ff7..c4eb6f6 100644
--- a/arch/powerpc/mm/44x_mmu.c
+++ b/arch/powerpc/mm/44x_mmu.c
@@ -225,7 +225,7 @@ void setup_initial_memory_limit(phys_addr_t first_memblock_base,
 
 	/* 44x has a 256M TLB entry pinned at boot */
 	size = (min_t(u64, first_memblock_size, PPC_PIN_SIZE));
-	memblock_set_current_limit(first_memblock_base + size);
+	memblock_set_current_limit_high(first_memblock_base + size);
 }
 
 #ifdef CONFIG_SMP
diff --git a/arch/powerpc/mm/fsl_booke_mmu.c b/arch/powerpc/mm/fsl_booke_mmu.c
index 07ba45b..c3d0662 100644
--- a/arch/powerpc/mm/fsl_booke_mmu.c
+++ b/arch/powerpc/mm/fsl_booke_mmu.c
@@ -230,7 +230,7 @@ void __init adjust_total_lowmem(void)
 	pr_cont("%lu Mb, residual: %dMb\n", tlbcam_sz(tlbcam_index - 1) >> 20,
 	        (unsigned int)((total_lowmem - __max_low_memory) >> 20));
 
-	memblock_set_current_limit(memstart_addr + __max_low_memory);
+	memblock_set_current_limit_high(memstart_addr + __max_low_memory);
 }
 
 void setup_initial_memory_limit(phys_addr_t first_memblock_base,
@@ -239,6 +239,6 @@ void setup_initial_memory_limit(phys_addr_t first_memblock_base,
 	phys_addr_t limit = first_memblock_base + first_memblock_size;
 
 	/* 64M mapped initially according to head_fsl_booke.S */
-	memblock_set_current_limit(min_t(u64, limit, 0x04000000));
+	memblock_set_current_limit_high(min_t(u64, limit, 0x04000000));
 }
 #endif
diff --git a/arch/powerpc/mm/hash_utils_64.c b/arch/powerpc/mm/hash_utils_64.c
index 6ecc38b..550c890 100644
--- a/arch/powerpc/mm/hash_utils_64.c
+++ b/arch/powerpc/mm/hash_utils_64.c
@@ -759,7 +759,7 @@ static void __init htab_initialize(void)
 		BUG_ON(htab_bolt_mapping(base, base + size, __pa(base),
 				prot, mmu_linear_psize, mmu_kernel_ssize));
 	}
-	memblock_set_current_limit(MEMBLOCK_ALLOC_ANYWHERE);
+	memblock_set_current_limit_high(MEMBLOCK_ALLOC_ANYWHERE);
 
 	/*
 	 * If we have a memory_limit and we've allocated TCEs then we need to
@@ -1432,5 +1432,5 @@ void setup_initial_memory_limit(phys_addr_t first_memblock_base,
 	ppc64_rma_size = min_t(u64, first_memblock_size, 0x40000000);
 
 	/* Finally limit subsequent allocations */
-	memblock_set_current_limit(ppc64_rma_size);
+	memblock_set_current_limit_high(ppc64_rma_size);
 }
diff --git a/arch/powerpc/mm/init_32.c b/arch/powerpc/mm/init_32.c
index 01e2db9..992728d 100644
--- a/arch/powerpc/mm/init_32.c
+++ b/arch/powerpc/mm/init_32.c
@@ -192,7 +192,7 @@ void __init MMU_init(void)
 #endif
 
 	/* Shortly after that, the entire linear mapping will be available */
-	memblock_set_current_limit(lowmem_end_addr);
+	memblock_set_current_limit_high(lowmem_end_addr);
 }
 
 /* This is only called until mem_init is done. */
@@ -214,6 +214,6 @@ void setup_initial_memory_limit(phys_addr_t first_memblock_base,
 	BUG_ON(first_memblock_base != 0);
 
 	/* 8xx can only access 8MB at the moment */
-	memblock_set_current_limit(min_t(u64, first_memblock_size, 0x00800000));
+	memblock_set_current_limit_high(min_t(u64, first_memblock_size, 0x00800000));
 }
 #endif /* CONFIG_8xx */
diff --git a/arch/powerpc/mm/ppc_mmu_32.c b/arch/powerpc/mm/ppc_mmu_32.c
index 11571e1..815dbe1 100644
--- a/arch/powerpc/mm/ppc_mmu_32.c
+++ b/arch/powerpc/mm/ppc_mmu_32.c
@@ -282,7 +282,7 @@ void setup_initial_memory_limit(phys_addr_t first_memblock_base,
 
 	/* 601 can only access 16MB at the moment */
 	if (PVR_VER(mfspr(SPRN_PVR)) == 1)
-		memblock_set_current_limit(min_t(u64, first_memblock_size, 0x01000000));
+		memblock_set_current_limit_high(min_t(u64, first_memblock_size, 0x01000000));
 	else /* Anything else has 256M mapped */
-		memblock_set_current_limit(min_t(u64, first_memblock_size, 0x10000000));
+		memblock_set_current_limit_high(min_t(u64, first_memblock_size, 0x10000000));
 }
diff --git a/arch/powerpc/mm/tlb_nohash.c b/arch/powerpc/mm/tlb_nohash.c
index 41cd68d..5e41488 100644
--- a/arch/powerpc/mm/tlb_nohash.c
+++ b/arch/powerpc/mm/tlb_nohash.c
@@ -640,7 +640,7 @@ static void __early_init_mmu(int boot_cpu)
 	 */
 	mb();
 
-	memblock_set_current_limit(linear_map_top);
+	memblock_set_current_limit_high(linear_map_top);
 }
 
 void __init early_init_mmu(void)
@@ -680,7 +680,7 @@ void setup_initial_memory_limit(phys_addr_t first_memblock_base,
 		ppc64_rma_size = min_t(u64, first_memblock_size, 0x40000000);
 
 	/* Finally limit subsequent allocations */
-	memblock_set_current_limit(first_memblock_base + ppc64_rma_size);
+	memblock_set_current_limit_high(first_memblock_base + ppc64_rma_size);
 }
 #else /* ! CONFIG_PPC64 */
 void __init early_init_mmu(void)
diff --git a/arch/unicore32/mm/mmu.c b/arch/unicore32/mm/mmu.c
index 4f5a532..278f7e3 100644
--- a/arch/unicore32/mm/mmu.c
+++ b/arch/unicore32/mm/mmu.c
@@ -287,7 +287,7 @@ static void __init sanity_check_meminfo(void)
 	int i, j;
 
 	lowmem_limit = __pa(vmalloc_min - 1) + 1;
-	memblock_set_current_limit(lowmem_limit);
+	memblock_set_current_limit_high(lowmem_limit);
 
 	for (i = 0, j = 0; i < meminfo.nr_banks; i++) {
 		struct membank *bank = &meminfo.bank[j];
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 382e20b..fa7b5f0 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -1060,7 +1060,7 @@ void __init setup_arch(char **cmdline_p)
 
 	cleanup_highmap();
 
-	memblock_set_current_limit(ISA_END_ADDRESS);
+	memblock_set_current_limit_high(ISA_END_ADDRESS);
 	memblock_x86_fill();
 
 	/*
@@ -1093,7 +1093,7 @@ void __init setup_arch(char **cmdline_p)
 
 	setup_real_mode();
 
-	memblock_set_current_limit(get_max_mapped());
+	memblock_set_current_limit_high(get_max_mapped());
 	dma_contiguous_reserve(0);
 
 	/*
diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index f0c0a91..c28cd6b 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -173,12 +173,12 @@ static inline void memblock_dump_all(void)
 }
 
 /**
- * memblock_set_current_limit - Set the current allocation limit to allow
- *                         limiting allocations to what is currently
+ * memblock_set_current_limit_high - Set the current allocation upper limit to
+ *                         allow limiting allocations to what is currently
  *                         accessible during boot
- * @limit: New limit value (physical address)
+ * @limit: New upper limit value (physical address)
  */
-void memblock_set_current_limit(phys_addr_t limit);
+void memblock_set_current_limit_high(phys_addr_t limit);
 
 
 /*
diff --git a/mm/memblock.c b/mm/memblock.c
index ff2226f..d351911 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -977,7 +977,7 @@ void __init_memblock memblock_trim_memory(phys_addr_t align)
 	}
 }
 
-void __init_memblock memblock_set_current_limit(phys_addr_t limit)
+void __init_memblock memblock_set_current_limit_high(phys_addr_t limit)
 {
 	memblock.current_limit_high = limit;
 }
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
