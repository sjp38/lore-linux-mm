Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id j267CMqi015345
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <linux-mm@kvack.org>; Sat, 5 Mar 2005 23:12:22 -0800
Received: from bix (shell0.pdx.osdl.net [10.9.0.31])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with SMTP id j267CLcN018176
	for <linux-mm@kvack.org>; Sat, 5 Mar 2005 23:12:21 -0800
Date: Sat, 5 Mar 2005 23:11:59 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Fw: [BK] flush_cache_page() pfn arg addition
Message-Id: <20050305231159.59893c49.akpm@osdl.org>
In-Reply-To: <20050305231013.20f30a1d.akpm@osdl.org>
References: <20050305231013.20f30a1d.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@osdl.org> wrote:
>
> 
> 
> Begin forwarded message:
> 
> Date: Sat, 5 Mar 2005 21:27:45 -0800
> From: "David S. Miller" <davem@davemloft.net>
> To: torvalds@osdl.org
> Cc: akpm@osdl.org, linux-arch -at- vger
> Subject: [BK] flush_cache_page() pfn arg addition
> 
> 
> 
> Linus, please pull from:
> 
> 	bk://kernel.bkbits.net/davem/flush_cache_page-2.6
> 
> to get these changesets.
> 

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/05 21:23:33-08:00 lethal@linux-sh.org 
#   [SH]: Cache flush simplifications after flush_cache_page() arg change.
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# arch/sh64/mm/cache.c
#   2005/03/05 21:23:02-08:00 lethal@linux-sh.org +1 -6
#   [SH]: Cache flush simplifications after flush_cache_page() arg change.
# 
# arch/sh/mm/cache-sh4.c
#   2005/03/05 21:23:02-08:00 lethal@linux-sh.org +1 -2
#   [SH]: Cache flush simplifications after flush_cache_page() arg change.
# 
# ChangeSet
#   2005/03/05 21:15:21-08:00 davem@picasso.davemloft.net 
#   Merge davem@nuts:/disk1/BK/flush_cache_page-2.6
#   into picasso.davemloft.net:/home/davem/src/BK/flush_cache_page-2.6
# 
# mm/rmap.c
#   2005/03/05 21:15:17-08:00 davem@picasso.davemloft.net +0 -0
#   Auto merged
# 
# mm/memory.c
#   2005/03/05 21:15:17-08:00 davem@picasso.davemloft.net +0 -0
#   Auto merged
# 
# include/asm-ppc64/cacheflush.h
#   2005/03/05 21:15:17-08:00 davem@picasso.davemloft.net +0 -0
#   Auto merged
# 
# include/asm-parisc/cacheflush.h
#   2005/03/05 21:15:17-08:00 davem@picasso.davemloft.net +0 -0
#   Auto merged
# 
# include/asm-arm/cacheflush.h
#   2005/03/05 21:15:17-08:00 davem@picasso.davemloft.net +0 -0
#   Auto merged
# 
# fs/binfmt_elf.c
#   2005/03/05 21:15:17-08:00 davem@picasso.davemloft.net +0 -0
#   Auto merged
# 
# ChangeSet
#   2005/02/25 16:36:06-08:00 davem@nuts.davemloft.net 
#   [MM]: Add 'pfn' arg to flush_cache_page().
#   
#   Based almost entirely upon a patch by Russell King.
#   
#   Signed-off-by: David S. Miller <davem@davemloft.net>
# 
# mm/rmap.c
#   2005/02/25 16:35:20-08:00 davem@nuts.davemloft.net +2 -2
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# mm/memory.c
#   2005/02/25 16:35:20-08:00 davem@nuts.davemloft.net +2 -2
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# mm/fremap.c
#   2005/02/25 16:35:20-08:00 davem@nuts.davemloft.net +1 -1
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# include/asm-x86_64/cacheflush.h
#   2005/02/25 16:35:20-08:00 davem@nuts.davemloft.net +1 -1
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# include/asm-v850/cacheflush.h
#   2005/02/25 16:35:20-08:00 davem@nuts.davemloft.net +1 -1
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# include/asm-sparc64/cacheflush.h
#   2005/02/25 16:35:20-08:00 davem@nuts.davemloft.net +7 -7
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# include/asm-sparc/cacheflush.h
#   2005/02/25 16:35:20-08:00 davem@nuts.davemloft.net +7 -7
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# include/asm-sh64/cacheflush.h
#   2005/02/25 16:35:20-08:00 davem@nuts.davemloft.net +3 -3
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# include/asm-sh/cpu-sh4/cacheflush.h
#   2005/02/25 16:35:20-08:00 davem@nuts.davemloft.net +1 -1
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# include/asm-sh/cpu-sh3/cacheflush.h
#   2005/02/25 16:35:20-08:00 davem@nuts.davemloft.net +3 -3
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# include/asm-sh/cpu-sh2/cacheflush.h
#   2005/02/25 16:35:20-08:00 davem@nuts.davemloft.net +2 -2
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# include/asm-sh/cacheflush.h
#   2005/02/25 16:35:20-08:00 davem@nuts.davemloft.net +2 -2
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# include/asm-s390/cacheflush.h
#   2005/02/25 16:35:20-08:00 davem@nuts.davemloft.net +1 -1
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# include/asm-ppc64/cacheflush.h
#   2005/02/25 16:35:20-08:00 davem@nuts.davemloft.net +1 -1
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# include/asm-ppc/cacheflush.h
#   2005/02/25 16:35:20-08:00 davem@nuts.davemloft.net +1 -1
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# include/asm-parisc/cacheflush.h
#   2005/02/25 16:35:20-08:00 davem@nuts.davemloft.net +3 -3
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# include/asm-mips/cacheflush.h
#   2005/02/25 16:35:20-08:00 davem@nuts.davemloft.net +2 -3
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# include/asm-m68knommu/cacheflush.h
#   2005/02/25 16:35:20-08:00 davem@nuts.davemloft.net +1 -1
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# include/asm-m68k/cacheflush.h
#   2005/02/25 16:35:20-08:00 davem@nuts.davemloft.net +7 -8
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# include/asm-m32r/cacheflush.h
#   2005/02/25 16:35:20-08:00 davem@nuts.davemloft.net +3 -3
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# include/asm-ia64/cacheflush.h
#   2005/02/25 16:35:20-08:00 davem@nuts.davemloft.net +1 -1
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# include/asm-i386/cacheflush.h
#   2005/02/25 16:35:20-08:00 davem@nuts.davemloft.net +1 -1
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# include/asm-h8300/cacheflush.h
#   2005/02/25 16:35:20-08:00 davem@nuts.davemloft.net +1 -1
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# include/asm-frv/cacheflush.h
#   2005/02/25 16:35:20-08:00 davem@nuts.davemloft.net +1 -1
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# include/asm-cris/cacheflush.h
#   2005/02/25 16:35:20-08:00 davem@nuts.davemloft.net +1 -1
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# include/asm-arm26/cacheflush.h
#   2005/02/25 16:35:20-08:00 davem@nuts.davemloft.net +1 -1
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# include/asm-arm/cacheflush.h
#   2005/02/25 16:35:20-08:00 davem@nuts.davemloft.net +8 -8
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# include/asm-alpha/cacheflush.h
#   2005/02/25 16:35:20-08:00 davem@nuts.davemloft.net +1 -1
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# fs/binfmt_elf.c
#   2005/02/25 16:35:19-08:00 davem@nuts.davemloft.net +1 -1
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# arch/sparc/mm/srmmu.c
#   2005/02/25 16:35:19-08:00 davem@nuts.davemloft.net +1 -2
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# arch/sh64/mm/cache.c
#   2005/02/25 16:35:19-08:00 davem@nuts.davemloft.net +4 -24
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# arch/sh/mm/cache-sh7705.c
#   2005/02/25 16:35:19-08:00 davem@nuts.davemloft.net +2 -18
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# arch/sh/mm/cache-sh4.c
#   2005/02/25 16:35:19-08:00 davem@nuts.davemloft.net +11 -30
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# arch/mips/mm/cache.c
#   2005/02/25 16:35:19-08:00 davem@nuts.davemloft.net +1 -1
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# arch/mips/mm/c-tx39.c
#   2005/02/25 16:35:19-08:00 davem@nuts.davemloft.net +1 -2
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# arch/mips/mm/c-sb1.c
#   2005/02/25 16:35:19-08:00 davem@nuts.davemloft.net +6 -5
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# arch/mips/mm/c-r4k.c
#   2005/02/25 16:35:19-08:00 davem@nuts.davemloft.net +1 -2
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# arch/mips/mm/c-r3k.c
#   2005/02/25 16:35:19-08:00 davem@nuts.davemloft.net +1 -2
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# arch/arm/mm/flush.c
#   2005/02/25 16:35:19-08:00 davem@nuts.davemloft.net +1 -1
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# arch/arm/mm/fault-armv.c
#   2005/02/25 16:35:19-08:00 davem@nuts.davemloft.net +2 -2
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
# Documentation/cachetlb.txt
#   2005/02/25 16:35:19-08:00 davem@nuts.davemloft.net +9 -3
#   [MM]: Add 'pfn' arg to flush_cache_page().
# 
diff -Nru a/Documentation/cachetlb.txt b/Documentation/cachetlb.txt
--- a/Documentation/cachetlb.txt	2005-03-05 23:11:46 -08:00
+++ b/Documentation/cachetlb.txt	2005-03-05 23:11:46 -08:00
@@ -155,7 +155,7 @@
 	   change_range_of_page_tables(mm, start, end);
 	   flush_tlb_range(vma, start, end);
 
-	3) flush_cache_page(vma, addr);
+	3) flush_cache_page(vma, addr, pfn);
 	   set_pte(pte_pointer, new_pte_val);
 	   flush_tlb_page(vma, addr);
 
@@ -203,7 +203,7 @@
 	call flush_cache_page (see below) for each entry which may be
 	modified.
 
-3) void flush_cache_page(struct vm_area_struct *vma, unsigned long addr)
+3) void flush_cache_page(struct vm_area_struct *vma, unsigned long addr, unsigned long pfn)
 
 	This time we need to remove a PAGE_SIZE sized range
 	from the cache.  The 'vma' is the backing structure used by
@@ -213,8 +213,14 @@
 	executable (and thus could be in the 'instruction cache' in
 	"Harvard" type cache layouts).
 
+	The 'pfn' indicates the physical page frame (shift this value
+	left by PAGE_SHIFT to get the physical address) that 'addr'
+	translates to.  It is this mapping which should be removed from
+	the cache.
+
 	After running, there will be no entries in the cache for
-	'vma->vm_mm' for virtual address 'addr'.
+	'vma->vm_mm' for virtual address 'addr' which translates
+	to 'pfn'.
 
 	This is used primarily during fault processing.
 
diff -Nru a/arch/arm/mm/fault-armv.c b/arch/arm/mm/fault-armv.c
--- a/arch/arm/mm/fault-armv.c	2005-03-05 23:11:46 -08:00
+++ b/arch/arm/mm/fault-armv.c	2005-03-05 23:11:46 -08:00
@@ -54,7 +54,7 @@
 	 * fault (ie, is old), we can safely ignore any issues.
 	 */
 	if (pte_present(entry) && pte_val(entry) & shared_pte_mask) {
-		flush_cache_page(vma, address);
+		flush_cache_page(vma, address, pte_pfn(entry));
 		pte_val(entry) &= ~shared_pte_mask;
 		set_pte(pte, entry);
 		flush_tlb_page(vma, address);
@@ -115,7 +115,7 @@
 	if (aliases)
 		adjust_pte(vma, addr);
 	else
-		flush_cache_page(vma, addr);
+		flush_cache_page(vma, addr, page_to_pfn(page));
 }
 
 /*
diff -Nru a/arch/arm/mm/flush.c b/arch/arm/mm/flush.c
--- a/arch/arm/mm/flush.c	2005-03-05 23:11:46 -08:00
+++ b/arch/arm/mm/flush.c	2005-03-05 23:11:46 -08:00
@@ -56,7 +56,7 @@
 		if (!(mpnt->vm_flags & VM_MAYSHARE))
 			continue;
 		offset = (pgoff - mpnt->vm_pgoff) << PAGE_SHIFT;
-		flush_cache_page(mpnt, mpnt->vm_start + offset);
+		flush_cache_page(mpnt, mpnt->vm_start + offset, page_to_pfn(page));
 		if (cache_is_vipt())
 			break;
 	}
diff -Nru a/arch/mips/mm/c-r3k.c b/arch/mips/mm/c-r3k.c
--- a/arch/mips/mm/c-r3k.c	2005-03-05 23:11:46 -08:00
+++ b/arch/mips/mm/c-r3k.c	2005-03-05 23:11:46 -08:00
@@ -254,8 +254,7 @@
 {
 }
 
-static void r3k_flush_cache_page(struct vm_area_struct *vma,
-	unsigned long page)
+static void r3k_flush_cache_page(struct vm_area_struct *vma, unsigned long page, unsigned long pfn)
 {
 }
 
diff -Nru a/arch/mips/mm/c-r4k.c b/arch/mips/mm/c-r4k.c
--- a/arch/mips/mm/c-r4k.c	2005-03-05 23:11:46 -08:00
+++ b/arch/mips/mm/c-r4k.c	2005-03-05 23:11:46 -08:00
@@ -426,8 +426,7 @@
 	}
 }
 
-static void r4k_flush_cache_page(struct vm_area_struct *vma,
-	unsigned long page)
+static void r4k_flush_cache_page(struct vm_area_struct *vma, unsigned long page, unsigned long pfn)
 {
 	struct flush_cache_page_args args;
 
diff -Nru a/arch/mips/mm/c-sb1.c b/arch/mips/mm/c-sb1.c
--- a/arch/mips/mm/c-sb1.c	2005-03-05 23:11:46 -08:00
+++ b/arch/mips/mm/c-sb1.c	2005-03-05 23:11:46 -08:00
@@ -160,8 +160,7 @@
  * dcache first, then invalidate the icache.  If the page isn't
  * executable, nothing is required.
  */
-static void local_sb1_flush_cache_page(struct vm_area_struct *vma,
-	unsigned long addr)
+static void local_sb1_flush_cache_page(struct vm_area_struct *vma, unsigned long addr, unsigned long pfn)
 {
 	int cpu = smp_processor_id();
 
@@ -183,17 +182,18 @@
 struct flush_cache_page_args {
 	struct vm_area_struct *vma;
 	unsigned long addr;
+	unsigned long pfn;
 };
 
 static void sb1_flush_cache_page_ipi(void *info)
 {
 	struct flush_cache_page_args *args = info;
 
-	local_sb1_flush_cache_page(args->vma, args->addr);
+	local_sb1_flush_cache_page(args->vma, args->addr, args->pfn);
 }
 
 /* Dirty dcache could be on another CPU, so do the IPIs */
-static void sb1_flush_cache_page(struct vm_area_struct *vma, unsigned long addr)
+static void sb1_flush_cache_page(struct vm_area_struct *vma, unsigned long addr, unsigned long pfn)
 {
 	struct flush_cache_page_args args;
 
@@ -203,10 +203,11 @@
 	addr &= PAGE_MASK;
 	args.vma = vma;
 	args.addr = addr;
+	args.pfn = pfn;
 	on_each_cpu(sb1_flush_cache_page_ipi, (void *) &args, 1, 1);
 }
 #else
-void sb1_flush_cache_page(struct vm_area_struct *vma, unsigned long addr)
+void sb1_flush_cache_page(struct vm_area_struct *vma, unsigned long addr, unsigned long pfn)
 	__attribute__((alias("local_sb1_flush_cache_page")));
 #endif
 
diff -Nru a/arch/mips/mm/c-tx39.c b/arch/mips/mm/c-tx39.c
--- a/arch/mips/mm/c-tx39.c	2005-03-05 23:11:46 -08:00
+++ b/arch/mips/mm/c-tx39.c	2005-03-05 23:11:46 -08:00
@@ -178,8 +178,7 @@
 	}
 }
 
-static void tx39_flush_cache_page(struct vm_area_struct *vma,
-				   unsigned long page)
+static void tx39_flush_cache_page(struct vm_area_struct *vma, unsigned long page, unsigned long pfn)
 {
 	int exec = vma->vm_flags & VM_EXEC;
 	struct mm_struct *mm = vma->vm_mm;
diff -Nru a/arch/mips/mm/cache.c b/arch/mips/mm/cache.c
--- a/arch/mips/mm/cache.c	2005-03-05 23:11:46 -08:00
+++ b/arch/mips/mm/cache.c	2005-03-05 23:11:46 -08:00
@@ -23,7 +23,7 @@
 void (*flush_cache_mm)(struct mm_struct *mm);
 void (*flush_cache_range)(struct vm_area_struct *vma, unsigned long start,
 	unsigned long end);
-void (*flush_cache_page)(struct vm_area_struct *vma, unsigned long page);
+void (*flush_cache_page)(struct vm_area_struct *vma, unsigned long page, unsigned long pfn);
 void (*flush_icache_range)(unsigned long start, unsigned long end);
 void (*flush_icache_page)(struct vm_area_struct *vma, struct page *page);
 
diff -Nru a/arch/sh/mm/cache-sh4.c b/arch/sh/mm/cache-sh4.c
--- a/arch/sh/mm/cache-sh4.c	2005-03-05 23:11:46 -08:00
+++ b/arch/sh/mm/cache-sh4.c	2005-03-05 23:11:46 -08:00
@@ -258,10 +258,16 @@
 	flush_cache_all();
 }
 
-static void __flush_cache_page(struct vm_area_struct *vma,
-			       unsigned long address,
-			       unsigned long phys)
+/*
+ * Write back and invalidate I/D-caches for the page.
+ *
+ * ADDR: Virtual Address (U0 address)
+ * PFN: Physical page number
+ */
+void flush_cache_page(struct vm_area_struct *vma, unsigned long address, unsigned long pfn)
 {
+	unsigned long phys = pfn << PAGE_SHIFT;
+
 	/* We only need to flush D-cache when we have alias */
 	if ((address^phys) & CACHE_ALIAS) {
 		/* Loop 4K of the D-cache */
@@ -342,32 +348,6 @@
 }
 
 /*
- * Write back and invalidate I/D-caches for the page.
- *
- * ADDR: Virtual Address (U0 address)
- */
-void flush_cache_page(struct vm_area_struct *vma, unsigned long address)
-{
-	pgd_t *dir;
-	pmd_t *pmd;
-	pte_t *pte;
-	pte_t entry;
-	unsigned long phys;
-
-	dir = pgd_offset(vma->vm_mm, address);
-	pmd = pmd_offset(dir, address);
-	if (pmd_none(*pmd) || pmd_bad(*pmd))
-		return;
-	pte = pte_offset_kernel(pmd, address);
-	entry = *pte;
-	if (!(pte_val(entry) & _PAGE_PRESENT))
-		return;
-
-	phys = pte_val(entry)&PTE_PHYS_MASK;
-	__flush_cache_page(vma, address, phys);
-}
-
-/*
  * flush_icache_user_range
  * @vma: VMA of the process
  * @page: page
@@ -377,6 +357,6 @@
 void flush_icache_user_range(struct vm_area_struct *vma,
 			     struct page *page, unsigned long addr, int len)
 {
-	__flush_cache_page(vma, addr, PHYSADDR(page_address(page)));
+	flush_cache_page(vma, addr, page_to_pfn(page));
 }
 
diff -Nru a/arch/sh/mm/cache-sh7705.c b/arch/sh/mm/cache-sh7705.c
--- a/arch/sh/mm/cache-sh7705.c	2005-03-05 23:11:46 -08:00
+++ b/arch/sh/mm/cache-sh7705.c	2005-03-05 23:11:46 -08:00
@@ -186,25 +186,9 @@
  *
  * ADDRESS: Virtual Address (U0 address)
  */
-void flush_cache_page(struct vm_area_struct *vma, unsigned long address)
+void flush_cache_page(struct vm_area_struct *vma, unsigned long address, unsigned long pfn)
 {
-	pgd_t *dir;
-	pmd_t *pmd;
-	pte_t *pte;
-	pte_t entry;
-	unsigned long phys;
-
-	dir = pgd_offset(vma->vm_mm, address);
-	pmd = pmd_offset(dir, address);
-	if (pmd_none(*pmd) || pmd_bad(*pmd))
-		return;
-	pte = pte_offset(pmd, address);
-	entry = *pte;
-	if (pte_none(entry) || !pte_present(entry))
-		return;
-
-	phys = pte_val(entry)&PTE_PHYS_MASK;
-	__flush_dcache_page(phys);
+	__flush_dcache_page(pfn << PAGE_SHIFT);
 }
 
 /*
diff -Nru a/arch/sh64/mm/cache.c b/arch/sh64/mm/cache.c
--- a/arch/sh64/mm/cache.c	2005-03-05 23:11:46 -08:00
+++ b/arch/sh64/mm/cache.c	2005-03-05 23:11:46 -08:00
@@ -573,31 +573,6 @@
 	}
 }
 
-static void sh64_dcache_purge_virt_page(struct mm_struct *mm, unsigned long eaddr)
-{
-	unsigned long phys;
-	pgd_t *pgd;
-	pmd_t *pmd;
-	pte_t *pte;
-	pte_t entry;
-
-	pgd = pgd_offset(mm, eaddr);
-	pmd = pmd_offset(pgd, eaddr);
-
-	if (pmd_none(*pmd) || pmd_bad(*pmd))
-		return;
-
-	pte = pte_offset_kernel(pmd, eaddr);
-	entry = *pte;
-
-	if (pte_none(entry) || !pte_present(entry))
-		return;
-
-	phys = pte_val(entry) & PAGE_MASK;
-
-	sh64_dcache_purge_phy_page(phys);
-}
-
 static void sh64_dcache_purge_user_page(struct mm_struct *mm, unsigned long eaddr)
 {
 	pgd_t *pgd;
@@ -904,7 +879,7 @@
 
 /****************************************************************************/
 
-void flush_cache_page(struct vm_area_struct *vma, unsigned long eaddr)
+void flush_cache_page(struct vm_area_struct *vma, unsigned long eaddr, unsigned long pfn)
 {
 	/* Invalidate any entries in either cache for the vma within the user
 	   address space vma->vm_mm for the page starting at virtual address
@@ -915,7 +890,7 @@
 	   Note(1), this is called with mm->page_table_lock held.
 	   */
 
-	sh64_dcache_purge_virt_page(vma->vm_mm, eaddr);
+	sh64_dcache_purge_phy_page(pfn << PAGE_SHIFT);
 
 	if (vma->vm_flags & VM_EXEC) {
 		sh64_icache_inv_user_page(vma, eaddr);
diff -Nru a/arch/sparc/mm/srmmu.c b/arch/sparc/mm/srmmu.c
--- a/arch/sparc/mm/srmmu.c	2005-03-05 23:11:46 -08:00
+++ b/arch/sparc/mm/srmmu.c	2005-03-05 23:11:46 -08:00
@@ -1003,8 +1003,7 @@
 extern void viking_flush_cache_mm(struct mm_struct *mm);
 extern void viking_flush_cache_range(struct vm_area_struct *vma, unsigned long start,
 				     unsigned long end);
-extern void viking_flush_cache_page(struct vm_area_struct *vma,
-				    unsigned long page);
+extern void viking_flush_cache_page(struct vm_area_struct *vma, unsigned long page);
 extern void viking_flush_page_to_ram(unsigned long page);
 extern void viking_flush_page_for_dma(unsigned long page);
 extern void viking_flush_sig_insns(struct mm_struct *mm, unsigned long addr);
diff -Nru a/fs/binfmt_elf.c b/fs/binfmt_elf.c
--- a/fs/binfmt_elf.c	2005-03-05 23:11:46 -08:00
+++ b/fs/binfmt_elf.c	2005-03-05 23:11:46 -08:00
@@ -1603,7 +1603,7 @@
 					DUMP_SEEK (file->f_pos + PAGE_SIZE);
 				} else {
 					void *kaddr;
-					flush_cache_page(vma, addr);
+					flush_cache_page(vma, addr, page_to_pfn(page));
 					kaddr = kmap(page);
 					if ((size += PAGE_SIZE) > limit ||
 					    !dump_write(file, kaddr,
diff -Nru a/include/asm-alpha/cacheflush.h b/include/asm-alpha/cacheflush.h
--- a/include/asm-alpha/cacheflush.h	2005-03-05 23:11:46 -08:00
+++ b/include/asm-alpha/cacheflush.h	2005-03-05 23:11:46 -08:00
@@ -8,7 +8,7 @@
 #define flush_cache_all()			do { } while (0)
 #define flush_cache_mm(mm)			do { } while (0)
 #define flush_cache_range(vma, start, end)	do { } while (0)
-#define flush_cache_page(vma, vmaddr)		do { } while (0)
+#define flush_cache_page(vma, vmaddr, pfn)	do { } while (0)
 #define flush_dcache_page(page)			do { } while (0)
 #define flush_dcache_mmap_lock(mapping)		do { } while (0)
 #define flush_dcache_mmap_unlock(mapping)	do { } while (0)
diff -Nru a/include/asm-arm/cacheflush.h b/include/asm-arm/cacheflush.h
--- a/include/asm-arm/cacheflush.h	2005-03-05 23:11:46 -08:00
+++ b/include/asm-arm/cacheflush.h	2005-03-05 23:11:46 -08:00
@@ -237,16 +237,16 @@
  * space" model to handle this.
  */
 #define copy_to_user_page(vma, page, vaddr, dst, src, len) \
-	do {					\
-		flush_cache_page(vma, vaddr);	\
-		memcpy(dst, src, len);		\
-		flush_dcache_page(page);	\
+	do {							\
+		flush_cache_page(vma, vaddr, page_to_pfn(page));\
+		memcpy(dst, src, len);				\
+		flush_dcache_page(page);			\
 	} while (0)
 
 #define copy_from_user_page(vma, page, vaddr, dst, src, len) \
-	do {					\
-		flush_cache_page(vma, vaddr);	\
-		memcpy(dst, src, len);		\
+	do {							\
+		flush_cache_page(vma, vaddr, page_to_pfn(page));\
+		memcpy(dst, src, len);				\
 	} while (0)
 
 /*
@@ -269,7 +269,7 @@
 }
 
 static inline void
-flush_cache_page(struct vm_area_struct *vma, unsigned long user_addr)
+flush_cache_page(struct vm_area_struct *vma, unsigned long user_addr, unsigned long pfn)
 {
 	if (cpu_isset(smp_processor_id(), vma->vm_mm->cpu_vm_mask)) {
 		unsigned long addr = user_addr & PAGE_MASK;
diff -Nru a/include/asm-arm26/cacheflush.h b/include/asm-arm26/cacheflush.h
--- a/include/asm-arm26/cacheflush.h	2005-03-05 23:11:46 -08:00
+++ b/include/asm-arm26/cacheflush.h	2005-03-05 23:11:46 -08:00
@@ -23,7 +23,7 @@
 #define flush_cache_all()                       do { } while (0)
 #define flush_cache_mm(mm)                      do { } while (0)
 #define flush_cache_range(vma,start,end)        do { } while (0)
-#define flush_cache_page(vma,vmaddr)            do { } while (0)
+#define flush_cache_page(vma,vmaddr,pfn)        do { } while (0)
 #define flush_cache_vmap(start, end)		do { } while (0)
 #define flush_cache_vunmap(start, end)		do { } while (0)
 
diff -Nru a/include/asm-cris/cacheflush.h b/include/asm-cris/cacheflush.h
--- a/include/asm-cris/cacheflush.h	2005-03-05 23:11:46 -08:00
+++ b/include/asm-cris/cacheflush.h	2005-03-05 23:11:46 -08:00
@@ -10,7 +10,7 @@
 #define flush_cache_all()			do { } while (0)
 #define flush_cache_mm(mm)			do { } while (0)
 #define flush_cache_range(vma, start, end)	do { } while (0)
-#define flush_cache_page(vma, vmaddr)		do { } while (0)
+#define flush_cache_page(vma, vmaddr, pfn)	do { } while (0)
 #define flush_dcache_page(page)			do { } while (0)
 #define flush_dcache_mmap_lock(mapping)		do { } while (0)
 #define flush_dcache_mmap_unlock(mapping)	do { } while (0)
diff -Nru a/include/asm-frv/cacheflush.h b/include/asm-frv/cacheflush.h
--- a/include/asm-frv/cacheflush.h	2005-03-05 23:11:46 -08:00
+++ b/include/asm-frv/cacheflush.h	2005-03-05 23:11:46 -08:00
@@ -21,7 +21,7 @@
 #define flush_cache_all()			do {} while(0)
 #define flush_cache_mm(mm)			do {} while(0)
 #define flush_cache_range(mm, start, end)	do {} while(0)
-#define flush_cache_page(vma, vmaddr)		do {} while(0)
+#define flush_cache_page(vma, vmaddr, pfn)	do {} while(0)
 #define flush_cache_vmap(start, end)		do {} while(0)
 #define flush_cache_vunmap(start, end)		do {} while(0)
 #define flush_dcache_mmap_lock(mapping)		do {} while(0)
diff -Nru a/include/asm-h8300/cacheflush.h b/include/asm-h8300/cacheflush.h
--- a/include/asm-h8300/cacheflush.h	2005-03-05 23:11:46 -08:00
+++ b/include/asm-h8300/cacheflush.h	2005-03-05 23:11:46 -08:00
@@ -13,7 +13,7 @@
 #define flush_cache_all()
 #define	flush_cache_mm(mm)
 #define	flush_cache_range(vma,a,b)
-#define	flush_cache_page(vma,p)
+#define	flush_cache_page(vma,p,pfn)
 #define	flush_dcache_page(page)
 #define	flush_dcache_mmap_lock(mapping)
 #define	flush_dcache_mmap_unlock(mapping)
diff -Nru a/include/asm-i386/cacheflush.h b/include/asm-i386/cacheflush.h
--- a/include/asm-i386/cacheflush.h	2005-03-05 23:11:46 -08:00
+++ b/include/asm-i386/cacheflush.h	2005-03-05 23:11:46 -08:00
@@ -8,7 +8,7 @@
 #define flush_cache_all()			do { } while (0)
 #define flush_cache_mm(mm)			do { } while (0)
 #define flush_cache_range(vma, start, end)	do { } while (0)
-#define flush_cache_page(vma, vmaddr)		do { } while (0)
+#define flush_cache_page(vma, vmaddr, pfn)	do { } while (0)
 #define flush_dcache_page(page)			do { } while (0)
 #define flush_dcache_mmap_lock(mapping)		do { } while (0)
 #define flush_dcache_mmap_unlock(mapping)	do { } while (0)
diff -Nru a/include/asm-ia64/cacheflush.h b/include/asm-ia64/cacheflush.h
--- a/include/asm-ia64/cacheflush.h	2005-03-05 23:11:46 -08:00
+++ b/include/asm-ia64/cacheflush.h	2005-03-05 23:11:46 -08:00
@@ -19,7 +19,7 @@
 #define flush_cache_all()			do { } while (0)
 #define flush_cache_mm(mm)			do { } while (0)
 #define flush_cache_range(vma, start, end)	do { } while (0)
-#define flush_cache_page(vma, vmaddr)		do { } while (0)
+#define flush_cache_page(vma, vmaddr, pfn)	do { } while (0)
 #define flush_icache_page(vma,page)		do { } while (0)
 #define flush_cache_vmap(start, end)		do { } while (0)
 #define flush_cache_vunmap(start, end)		do { } while (0)
diff -Nru a/include/asm-m32r/cacheflush.h b/include/asm-m32r/cacheflush.h
--- a/include/asm-m32r/cacheflush.h	2005-03-05 23:11:46 -08:00
+++ b/include/asm-m32r/cacheflush.h	2005-03-05 23:11:46 -08:00
@@ -11,7 +11,7 @@
 #define flush_cache_all()			do { } while (0)
 #define flush_cache_mm(mm)			do { } while (0)
 #define flush_cache_range(vma, start, end)	do { } while (0)
-#define flush_cache_page(vma, vmaddr)		do { } while (0)
+#define flush_cache_page(vma, vmaddr, pfn)	do { } while (0)
 #define flush_dcache_page(page)			do { } while (0)
 #define flush_dcache_mmap_lock(mapping)		do { } while (0)
 #define flush_dcache_mmap_unlock(mapping)	do { } while (0)
@@ -31,7 +31,7 @@
 #define flush_cache_all()			do { } while (0)
 #define flush_cache_mm(mm)			do { } while (0)
 #define flush_cache_range(vma, start, end)	do { } while (0)
-#define flush_cache_page(vma, vmaddr)		do { } while (0)
+#define flush_cache_page(vma, vmaddr, pfn)	do { } while (0)
 #define flush_dcache_page(page)			do { } while (0)
 #define flush_dcache_mmap_lock(mapping)		do { } while (0)
 #define flush_dcache_mmap_unlock(mapping)	do { } while (0)
@@ -43,7 +43,7 @@
 #define flush_cache_all()			do { } while (0)
 #define flush_cache_mm(mm)			do { } while (0)
 #define flush_cache_range(vma, start, end)	do { } while (0)
-#define flush_cache_page(vma, vmaddr)		do { } while (0)
+#define flush_cache_page(vma, vmaddr, pfn)	do { } while (0)
 #define flush_dcache_page(page)			do { } while (0)
 #define flush_dcache_mmap_lock(mapping)		do { } while (0)
 #define flush_dcache_mmap_unlock(mapping)	do { } while (0)
diff -Nru a/include/asm-m68k/cacheflush.h b/include/asm-m68k/cacheflush.h
--- a/include/asm-m68k/cacheflush.h	2005-03-05 23:11:46 -08:00
+++ b/include/asm-m68k/cacheflush.h	2005-03-05 23:11:46 -08:00
@@ -99,8 +99,7 @@
 	        __flush_cache_030();
 }
 
-static inline void flush_cache_page(struct vm_area_struct *vma,
-				    unsigned long vmaddr)
+static inline void flush_cache_page(struct vm_area_struct *vma, unsigned long vmaddr, unsigned long pfn)
 {
 	if (vma->vm_mm == current->mm)
 	        __flush_cache_030();
@@ -134,15 +133,15 @@
 #define flush_icache_user_range(vma,pg,adr,len)	do { } while (0)
 
 #define copy_to_user_page(vma, page, vaddr, dst, src, len) \
-	do {					\
-		flush_cache_page(vma, vaddr);	\
-		memcpy(dst, src, len);		\
+	do {							\
+		flush_cache_page(vma, vaddr, page_to_pfn(page));\
+		memcpy(dst, src, len);				\
 	} while (0)
 
 #define copy_from_user_page(vma, page, vaddr, dst, src, len) \
-	do {					\
-		flush_cache_page(vma, vaddr);	\
-		memcpy(dst, src, len);		\
+	do {							\
+		flush_cache_page(vma, vaddr, page_to_pfn(page));\
+		memcpy(dst, src, len);				\
 	} while (0)
 
 extern void flush_icache_range(unsigned long address, unsigned long endaddr);
diff -Nru a/include/asm-m68knommu/cacheflush.h b/include/asm-m68knommu/cacheflush.h
--- a/include/asm-m68knommu/cacheflush.h	2005-03-05 23:11:46 -08:00
+++ b/include/asm-m68knommu/cacheflush.h	2005-03-05 23:11:46 -08:00
@@ -9,7 +9,7 @@
 #define flush_cache_all()			__flush_cache_all()
 #define flush_cache_mm(mm)			do { } while (0)
 #define flush_cache_range(vma, start, end)	do { } while (0)
-#define flush_cache_page(vma, vmaddr)		do { } while (0)
+#define flush_cache_page(vma, vmaddr, pfn)	do { } while (0)
 #define flush_dcache_range(start,len)		do { } while (0)
 #define flush_dcache_page(page)			do { } while (0)
 #define flush_dcache_mmap_lock(mapping)		do { } while (0)
diff -Nru a/include/asm-mips/cacheflush.h b/include/asm-mips/cacheflush.h
--- a/include/asm-mips/cacheflush.h	2005-03-05 23:11:46 -08:00
+++ b/include/asm-mips/cacheflush.h	2005-03-05 23:11:46 -08:00
@@ -17,7 +17,7 @@
  *
  *  - flush_cache_all() flushes entire cache
  *  - flush_cache_mm(mm) flushes the specified mm context's cache lines
- *  - flush_cache_page(mm, vmaddr) flushes a single page
+ *  - flush_cache_page(mm, vmaddr, pfn) flushes a single page
  *  - flush_cache_range(vma, start, end) flushes a range of pages
  *  - flush_icache_range(start, end) flush a range of instructions
  *  - flush_dcache_page(pg) flushes(wback&invalidates) a page for dcache
@@ -34,8 +34,7 @@
 extern void (*flush_cache_mm)(struct mm_struct *mm);
 extern void (*flush_cache_range)(struct vm_area_struct *vma,
 	unsigned long start, unsigned long end);
-extern void (*flush_cache_page)(struct vm_area_struct *vma,
-	unsigned long page);
+extern void (*flush_cache_page)(struct vm_area_struct *vma, unsigned long page, unsigned long pfn);
 extern void __flush_dcache_page(struct page *page);
 
 static inline void flush_dcache_page(struct page *page)
diff -Nru a/include/asm-parisc/cacheflush.h b/include/asm-parisc/cacheflush.h
--- a/include/asm-parisc/cacheflush.h	2005-03-05 23:11:46 -08:00
+++ b/include/asm-parisc/cacheflush.h	2005-03-05 23:11:46 -08:00
@@ -67,14 +67,14 @@
 
 #define copy_to_user_page(vma, page, vaddr, dst, src, len) \
 do { \
-	flush_cache_page(vma, vaddr); \
+	flush_cache_page(vma, vaddr, page_to_pfn(page)); \
 	memcpy(dst, src, len); \
 	flush_kernel_dcache_range_asm((unsigned long)dst, (unsigned long)dst + len); \
 } while (0)
 
 #define copy_from_user_page(vma, page, vaddr, dst, src, len) \
 do { \
-	flush_cache_page(vma, vaddr); \
+	flush_cache_page(vma, vaddr, page_to_pfn(page)); \
 	memcpy(dst, src, len); \
 } while (0)
 
@@ -170,7 +170,7 @@
 }
 
 static inline void
-flush_cache_page(struct vm_area_struct *vma, unsigned long vmaddr)
+flush_cache_page(struct vm_area_struct *vma, unsigned long vmaddr, unsigned long pfn)
 {
 	BUG_ON(!vma->vm_mm->context);
 
diff -Nru a/include/asm-ppc/cacheflush.h b/include/asm-ppc/cacheflush.h
--- a/include/asm-ppc/cacheflush.h	2005-03-05 23:11:46 -08:00
+++ b/include/asm-ppc/cacheflush.h	2005-03-05 23:11:46 -08:00
@@ -22,7 +22,7 @@
 #define flush_cache_all()		do { } while (0)
 #define flush_cache_mm(mm)		do { } while (0)
 #define flush_cache_range(vma, a, b)	do { } while (0)
-#define flush_cache_page(vma, p)	do { } while (0)
+#define flush_cache_page(vma, p, pfn)	do { } while (0)
 #define flush_icache_page(vma, page)	do { } while (0)
 #define flush_cache_vmap(start, end)	do { } while (0)
 #define flush_cache_vunmap(start, end)	do { } while (0)
diff -Nru a/include/asm-ppc64/cacheflush.h b/include/asm-ppc64/cacheflush.h
--- a/include/asm-ppc64/cacheflush.h	2005-03-05 23:11:46 -08:00
+++ b/include/asm-ppc64/cacheflush.h	2005-03-05 23:11:46 -08:00
@@ -12,7 +12,7 @@
 #define flush_cache_all()			do { } while (0)
 #define flush_cache_mm(mm)			do { } while (0)
 #define flush_cache_range(vma, start, end)	do { } while (0)
-#define flush_cache_page(vma, vmaddr)		do { } while (0)
+#define flush_cache_page(vma, vmaddr, pfn)	do { } while (0)
 #define flush_icache_page(vma, page)		do { } while (0)
 #define flush_cache_vmap(start, end)		do { } while (0)
 #define flush_cache_vunmap(start, end)		do { } while (0)
diff -Nru a/include/asm-s390/cacheflush.h b/include/asm-s390/cacheflush.h
--- a/include/asm-s390/cacheflush.h	2005-03-05 23:11:46 -08:00
+++ b/include/asm-s390/cacheflush.h	2005-03-05 23:11:46 -08:00
@@ -8,7 +8,7 @@
 #define flush_cache_all()			do { } while (0)
 #define flush_cache_mm(mm)			do { } while (0)
 #define flush_cache_range(vma, start, end)	do { } while (0)
-#define flush_cache_page(vma, vmaddr)		do { } while (0)
+#define flush_cache_page(vma, vmaddr, pfn)	do { } while (0)
 #define flush_dcache_page(page)			do { } while (0)
 #define flush_dcache_mmap_lock(mapping)		do { } while (0)
 #define flush_dcache_mmap_unlock(mapping)	do { } while (0)
diff -Nru a/include/asm-sh/cacheflush.h b/include/asm-sh/cacheflush.h
--- a/include/asm-sh/cacheflush.h	2005-03-05 23:11:46 -08:00
+++ b/include/asm-sh/cacheflush.h	2005-03-05 23:11:46 -08:00
@@ -15,14 +15,14 @@
 
 #define copy_to_user_page(vma, page, vaddr, dst, src, len) \
 	do {							\
-		flush_cache_page(vma, vaddr);			\
+		flush_cache_page(vma, vaddr, page_to_pfn(page));\
 		memcpy(dst, src, len);				\
 		flush_icache_user_range(vma, page, vaddr, len);	\
 	} while (0)
 
 #define copy_from_user_page(vma, page, vaddr, dst, src, len) \
 	do {							\
-		flush_cache_page(vma, vaddr);			\
+		flush_cache_page(vma, vaddr, page_to_pfn(page));\
 		memcpy(dst, src, len);				\
 	} while (0)
 
diff -Nru a/include/asm-sh/cpu-sh2/cacheflush.h b/include/asm-sh/cpu-sh2/cacheflush.h
--- a/include/asm-sh/cpu-sh2/cacheflush.h	2005-03-05 23:11:46 -08:00
+++ b/include/asm-sh/cpu-sh2/cacheflush.h	2005-03-05 23:11:46 -08:00
@@ -15,7 +15,7 @@
  *
  *  - flush_cache_all() flushes entire cache
  *  - flush_cache_mm(mm) flushes the specified mm context's cache lines
- *  - flush_cache_page(mm, vmaddr) flushes a single page
+ *  - flush_cache_page(mm, vmaddr, pfn) flushes a single page
  *  - flush_cache_range(vma, start, end) flushes a range of pages
  *
  *  - flush_dcache_page(pg) flushes(wback&invalidates) a page for dcache
@@ -28,7 +28,7 @@
 #define flush_cache_all()			do { } while (0)
 #define flush_cache_mm(mm)			do { } while (0)
 #define flush_cache_range(vma, start, end)	do { } while (0)
-#define flush_cache_page(vma, vmaddr)		do { } while (0)
+#define flush_cache_page(vma, vmaddr, pfn)	do { } while (0)
 #define flush_dcache_page(page)			do { } while (0)
 #define flush_dcache_mmap_lock(mapping)		do { } while (0)
 #define flush_dcache_mmap_unlock(mapping)	do { } while (0)
diff -Nru a/include/asm-sh/cpu-sh3/cacheflush.h b/include/asm-sh/cpu-sh3/cacheflush.h
--- a/include/asm-sh/cpu-sh3/cacheflush.h	2005-03-05 23:11:46 -08:00
+++ b/include/asm-sh/cpu-sh3/cacheflush.h	2005-03-05 23:11:46 -08:00
@@ -15,7 +15,7 @@
  *
  *  - flush_cache_all() flushes entire cache
  *  - flush_cache_mm(mm) flushes the specified mm context's cache lines
- *  - flush_cache_page(mm, vmaddr) flushes a single page
+ *  - flush_cache_page(mm, vmaddr, pfn) flushes a single page
  *  - flush_cache_range(vma, start, end) flushes a range of pages
  *
  *  - flush_dcache_page(pg) flushes(wback&invalidates) a page for dcache
@@ -43,7 +43,7 @@
 extern void flush_cache_mm(struct mm_struct *mm);
 extern void flush_cache_range(struct vm_area_struct *vma, unsigned long start,
                               unsigned long end);
-extern void flush_cache_page(struct vm_area_struct *vma, unsigned long addr);
+extern void flush_cache_page(struct vm_area_struct *vma, unsigned long addr, unsigned long pfn);
 extern void flush_dcache_page(struct page *pg);
 extern void flush_icache_range(unsigned long start, unsigned long end);
 extern void flush_icache_page(struct vm_area_struct *vma, struct page *page);
@@ -68,7 +68,7 @@
 #define flush_cache_all()			do { } while (0)
 #define flush_cache_mm(mm)			do { } while (0)
 #define flush_cache_range(vma, start, end)	do { } while (0)
-#define flush_cache_page(vma, vmaddr)		do { } while (0)
+#define flush_cache_page(vma, vmaddr, pfn)	do { } while (0)
 #define flush_dcache_page(page)			do { } while (0)
 #define flush_dcache_mmap_lock(mapping)		do { } while (0)
 #define flush_dcache_mmap_unlock(mapping)	do { } while (0)
diff -Nru a/include/asm-sh/cpu-sh4/cacheflush.h b/include/asm-sh/cpu-sh4/cacheflush.h
--- a/include/asm-sh/cpu-sh4/cacheflush.h	2005-03-05 23:11:46 -08:00
+++ b/include/asm-sh/cpu-sh4/cacheflush.h	2005-03-05 23:11:46 -08:00
@@ -28,7 +28,7 @@
 extern void flush_cache_mm(struct mm_struct *mm);
 extern void flush_cache_range(struct vm_area_struct *vma, unsigned long start,
 			      unsigned long end);
-extern void flush_cache_page(struct vm_area_struct *vma, unsigned long addr);
+extern void flush_cache_page(struct vm_area_struct *vma, unsigned long addr, unsigned long pfn);
 extern void flush_dcache_page(struct page *pg);
 
 #define flush_dcache_mmap_lock(mapping)		do { } while (0)
diff -Nru a/include/asm-sh64/cacheflush.h b/include/asm-sh64/cacheflush.h
--- a/include/asm-sh64/cacheflush.h	2005-03-05 23:11:46 -08:00
+++ b/include/asm-sh64/cacheflush.h	2005-03-05 23:11:46 -08:00
@@ -14,7 +14,7 @@
 extern void flush_cache_sigtramp(unsigned long start, unsigned long end);
 extern void flush_cache_range(struct vm_area_struct *vma, unsigned long start,
 			      unsigned long end);
-extern void flush_cache_page(struct vm_area_struct *vma, unsigned long addr);
+extern void flush_cache_page(struct vm_area_struct *vma, unsigned long addr, unsigned long pfn);
 extern void flush_dcache_page(struct page *pg);
 extern void flush_icache_range(unsigned long start, unsigned long end);
 extern void flush_icache_user_range(struct vm_area_struct *vma,
@@ -31,14 +31,14 @@
 
 #define copy_to_user_page(vma, page, vaddr, dst, src, len) \
 	do {							\
-		flush_cache_page(vma, vaddr);			\
+		flush_cache_page(vma, vaddr, page_to_pfn(page));\
 		memcpy(dst, src, len);				\
 		flush_icache_user_range(vma, page, vaddr, len);	\
 	} while (0)
 
 #define copy_from_user_page(vma, page, vaddr, dst, src, len) \
 	do {							\
-		flush_cache_page(vma, vaddr);			\
+		flush_cache_page(vma, vaddr, page_to_pfn(page));\
 		memcpy(dst, src, len);				\
 	} while (0)
 
diff -Nru a/include/asm-sparc/cacheflush.h b/include/asm-sparc/cacheflush.h
--- a/include/asm-sparc/cacheflush.h	2005-03-05 23:11:46 -08:00
+++ b/include/asm-sparc/cacheflush.h	2005-03-05 23:11:46 -08:00
@@ -50,21 +50,21 @@
 #define flush_cache_all() BTFIXUP_CALL(flush_cache_all)()
 #define flush_cache_mm(mm) BTFIXUP_CALL(flush_cache_mm)(mm)
 #define flush_cache_range(vma,start,end) BTFIXUP_CALL(flush_cache_range)(vma,start,end)
-#define flush_cache_page(vma,addr) BTFIXUP_CALL(flush_cache_page)(vma,addr)
+#define flush_cache_page(vma,addr,pfn) BTFIXUP_CALL(flush_cache_page)(vma,addr)
 #define flush_icache_range(start, end)		do { } while (0)
 #define flush_icache_page(vma, pg)		do { } while (0)
 
 #define flush_icache_user_range(vma,pg,adr,len)	do { } while (0)
 
 #define copy_to_user_page(vma, page, vaddr, dst, src, len) \
-	do {					\
-		flush_cache_page(vma, vaddr);	\
-		memcpy(dst, src, len);		\
+	do {							\
+		flush_cache_page(vma, vaddr, page_to_pfn(page));\
+		memcpy(dst, src, len);				\
 	} while (0)
 #define copy_from_user_page(vma, page, vaddr, dst, src, len) \
-	do {					\
-		flush_cache_page(vma, vaddr);	\
-		memcpy(dst, src, len);		\
+	do {							\
+		flush_cache_page(vma, vaddr, page_to_pfn(page));\
+		memcpy(dst, src, len);				\
 	} while (0)
 
 BTFIXUPDEF_CALL(void, __flush_page_to_ram, unsigned long)
diff -Nru a/include/asm-sparc64/cacheflush.h b/include/asm-sparc64/cacheflush.h
--- a/include/asm-sparc64/cacheflush.h	2005-03-05 23:11:46 -08:00
+++ b/include/asm-sparc64/cacheflush.h	2005-03-05 23:11:46 -08:00
@@ -11,7 +11,7 @@
 	do { if ((__mm) == current->mm) flushw_user(); } while(0)
 #define flush_cache_range(vma, start, end) \
 	flush_cache_mm((vma)->vm_mm)
-#define flush_cache_page(vma, page) \
+#define flush_cache_page(vma, page, pfn) \
 	flush_cache_mm((vma)->vm_mm)
 
 /* 
@@ -38,15 +38,15 @@
 #define flush_icache_user_range(vma,pg,adr,len)	do { } while (0)
 
 #define copy_to_user_page(vma, page, vaddr, dst, src, len) \
-	do {					\
-		flush_cache_page(vma, vaddr);	\
-		memcpy(dst, src, len);		\
+	do {							\
+		flush_cache_page(vma, vaddr, page_to_pfn(page));\
+		memcpy(dst, src, len);				\
 	} while (0)
 
 #define copy_from_user_page(vma, page, vaddr, dst, src, len) \
-	do {					\
-		flush_cache_page(vma, vaddr);	\
-		memcpy(dst, src, len);		\
+	do {							\
+		flush_cache_page(vma, vaddr, page_to_pfn(page));\
+		memcpy(dst, src, len);				\
 	} while (0)
 
 extern void flush_dcache_page(struct page *page);
diff -Nru a/include/asm-v850/cacheflush.h b/include/asm-v850/cacheflush.h
--- a/include/asm-v850/cacheflush.h	2005-03-05 23:11:46 -08:00
+++ b/include/asm-v850/cacheflush.h	2005-03-05 23:11:46 -08:00
@@ -25,7 +25,7 @@
 #define flush_cache_all()			((void)0)
 #define flush_cache_mm(mm)			((void)0)
 #define flush_cache_range(vma, start, end)	((void)0)
-#define flush_cache_page(vma, vmaddr)		((void)0)
+#define flush_cache_page(vma, vmaddr, pfn)	((void)0)
 #define flush_dcache_page(page)			((void)0)
 #define flush_dcache_mmap_lock(mapping)		((void)0)
 #define flush_dcache_mmap_unlock(mapping)	((void)0)
diff -Nru a/include/asm-x86_64/cacheflush.h b/include/asm-x86_64/cacheflush.h
--- a/include/asm-x86_64/cacheflush.h	2005-03-05 23:11:46 -08:00
+++ b/include/asm-x86_64/cacheflush.h	2005-03-05 23:11:46 -08:00
@@ -8,7 +8,7 @@
 #define flush_cache_all()			do { } while (0)
 #define flush_cache_mm(mm)			do { } while (0)
 #define flush_cache_range(vma, start, end)	do { } while (0)
-#define flush_cache_page(vma, vmaddr)		do { } while (0)
+#define flush_cache_page(vma, vmaddr, pfn)	do { } while (0)
 #define flush_dcache_page(page)			do { } while (0)
 #define flush_dcache_mmap_lock(mapping)		do { } while (0)
 #define flush_dcache_mmap_unlock(mapping)	do { } while (0)
diff -Nru a/mm/fremap.c b/mm/fremap.c
--- a/mm/fremap.c	2005-03-05 23:11:46 -08:00
+++ b/mm/fremap.c	2005-03-05 23:11:46 -08:00
@@ -30,7 +30,7 @@
 	if (pte_present(pte)) {
 		unsigned long pfn = pte_pfn(pte);
 
-		flush_cache_page(vma, addr);
+		flush_cache_page(vma, addr, pfn);
 		pte = ptep_clear_flush(vma, addr, ptep);
 		if (pfn_valid(pfn)) {
 			struct page *page = pfn_to_page(pfn);
diff -Nru a/mm/memory.c b/mm/memory.c
--- a/mm/memory.c	2005-03-05 23:11:46 -08:00
+++ b/mm/memory.c	2005-03-05 23:11:46 -08:00
@@ -1245,7 +1245,6 @@
 {
 	pte_t entry;
 
-	flush_cache_page(vma, address);
 	entry = maybe_mkwrite(pte_mkdirty(mk_pte(new_page, vma->vm_page_prot)),
 			      vma);
 	ptep_establish(vma, address, page_table, entry);
@@ -1297,7 +1296,7 @@
 		int reuse = can_share_swap_page(old_page);
 		unlock_page(old_page);
 		if (reuse) {
-			flush_cache_page(vma, address);
+			flush_cache_page(vma, address, pfn);
 			entry = maybe_mkwrite(pte_mkyoung(pte_mkdirty(pte)),
 					      vma);
 			ptep_set_access_flags(vma, address, page_table, entry, 1);
@@ -1340,6 +1339,7 @@
 			++mm->rss;
 		else
 			page_remove_rmap(old_page);
+		flush_cache_page(vma, address, pfn);
 		break_cow(vma, new_page, address, page_table);
 		lru_cache_add_active(new_page);
 		page_add_anon_rmap(new_page, vma, address);
diff -Nru a/mm/rmap.c b/mm/rmap.c
--- a/mm/rmap.c	2005-03-05 23:11:46 -08:00
+++ b/mm/rmap.c	2005-03-05 23:11:46 -08:00
@@ -573,7 +573,7 @@
 	}
 
 	/* Nuke the page table entry. */
-	flush_cache_page(vma, address);
+	flush_cache_page(vma, address, page_to_pfn(page));
 	pteval = ptep_clear_flush(vma, address, pte);
 
 	/* Move the dirty bit to the physical page now the pte is gone. */
@@ -690,7 +690,7 @@
 			continue;
 
 		/* Nuke the page table entry. */
-		flush_cache_page(vma, address);
+		flush_cache_page(vma, address, pfn);
 		pteval = ptep_clear_flush(vma, address, pte);
 
 		/* If nonlinear, store the file page offset in the pte. */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
