Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AD91EC7618A
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 06:17:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 65AD320868
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 06:17:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 65AD320868
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 164776B0008; Mon, 15 Jul 2019 02:17:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0ED6D6B000A; Mon, 15 Jul 2019 02:17:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED1806B000C; Mon, 15 Jul 2019 02:17:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 997686B0008
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 02:17:44 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id w25so12883183edu.11
        for <linux-mm@kvack.org>; Sun, 14 Jul 2019 23:17:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=m/ch1EJnhlU3hP8sI64woDPhA16LL6MnmQw+Y8E+S98=;
        b=AqkMePOfEyRSQbZanrYwnSl80J/Tdrou+qmCgmQsg0WUYLcXr1FmmzaI0/pc9ViR9o
         3x/xRLgaAb1IGUl3VToS3VSBf7eWycHJ6wqb1+5hqi8GxMT/IE+LL06EraaWwhwlbc4U
         fsnhf33zgrDWxSpfJWunsF4cwfDW/JEhgDZGfZ5OWrypp2oYImoofiZaasSpJG/lqEUy
         p7mkcUsLNO6PBDvfOlXqbtGHzZn99fDFR2zqhOmA6BCWhHhhln+2IQfdPs1oprzgUDwL
         j0oeKUQJnhCE5VJ5GwEWqNsv66LNH6mt3+ylDcYHvjf8ZYAR8LfncnjRJ+Hc1YSuWrlh
         rYZg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAXzUAeGTCJZjYtFNVZI0/01zHT6lnCnHBJRmVqb5QOor0E2hjCV
	6JOhAzMr8WHbbeSHEkhtEzUmfHfp5n/L8+eyVjnamM4k230eRqS00nkhOOQT2FtY55+rHUOdnIN
	FvO/t1X6jRz28FdseOlZ3aczCoE2qlzNP1VhkV/h0L+iauaT6+KB1aoYKm+/dp6uIUQ==
X-Received: by 2002:a50:89b4:: with SMTP id g49mr21300965edg.39.1563171464184;
        Sun, 14 Jul 2019 23:17:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJ1eExHN0/dUeKEmDwCPXNSoJF2AXcoL0p5mUR7eIa7xMStSjixa2WVRQASSoACpXdGRcy
X-Received: by 2002:a50:89b4:: with SMTP id g49mr21300908edg.39.1563171463221;
        Sun, 14 Jul 2019 23:17:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563171463; cv=none;
        d=google.com; s=arc-20160816;
        b=ckhVgYtVt3YxmO2FIaNsWFpW17sIRfeZqA7aBTh5RUytj9pm1QmQd/sjYwKZXiI3La
         0fOOknjZDK/+jACES5ikEyj1EVBgpYKXPGIW5PlT6/nwakKi1NQ8yL8t3PQz4wDRRswg
         +hiAUdpyGKtHt0CC1VXUNoX/PMveicstdNsWysZXaPTdio9GOEjnQ+HkLkvGY2fESwaJ
         lZio5TKjwIVwug+P4/YN2p4X5wGfyMHdZu6kGDBUaY9HHUAPtUCgKGusenXmsXtvVwbu
         tA5Yd5YKTIYESYB8Fa8kZjk3gnEoMbksBjSKvyLFhLNVG/Oyh5zB08VSYgYWJHfciyrH
         upmA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=m/ch1EJnhlU3hP8sI64woDPhA16LL6MnmQw+Y8E+S98=;
        b=hDvYsM4w5UeOvbKP+jI+srPaD8eDq9+OJ4xgDaceaxwiYAriu+775tPkLOvAJJXnHI
         jImYI5mWjGP6KNtv1tSbJ/PBIoyJtLeo/lpzJpAY5Bahy9mTNOEa2rqju6pNCovutzcM
         if0E8UqaYy17jNYrNSazKZtpR+xL09748ueHhOjZw3Tr1HJD9be8Fh7sB5mvmP9EkXTn
         w8/Zez/m1Lgy7yBxELAK4dw6cHm0jA2gOgIenw1LOAF9d138ouJmD3FVqqXJZeZswITr
         rJxH0FzDCL31SmwZ+fAGR9uAtvioM16YsCjBKt5zRzHIaYB3sYRtPLVqrJdwb4qo4Lfu
         5mCw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id t23si8882631eju.143.2019.07.14.23.17.42
        for <linux-mm@kvack.org>;
        Sun, 14 Jul 2019 23:17:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 46752337;
	Sun, 14 Jul 2019 23:17:42 -0700 (PDT)
Received: from p8cg001049571a15.blr.arm.com (p8cg001049571a15.blr.arm.com [10.162.40.143])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 17ABF3F71F;
	Sun, 14 Jul 2019 23:19:35 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	akpm@linux-foundation.org,
	catalin.marinas@arm.com,
	will.deacon@arm.com
Cc: mark.rutland@arm.com,
	mhocko@suse.com,
	ira.weiny@intel.com,
	david@redhat.com,
	cai@lca.pw,
	logang@deltatee.com,
	james.morse@arm.com,
	cpandya@codeaurora.org,
	arunks@codeaurora.org,
	dan.j.williams@intel.com,
	mgorman@techsingularity.net,
	osalvador@suse.de,
	ard.biesheuvel@arm.com,
	steve.capper@arm.com
Subject: [PATCH V6 RESEND 3/3] arm64/mm: Enable memory hot remove
Date: Mon, 15 Jul 2019 11:47:50 +0530
Message-Id: <1563171470-3117-4-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1563171470-3117-1-git-send-email-anshuman.khandual@arm.com>
References: <1563171470-3117-1-git-send-email-anshuman.khandual@arm.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The arch code for hot-remove must tear down portions of the linear map and
vmemmap corresponding to memory being removed. In both cases the page
tables mapping these regions must be freed, and when sparse vmemmap is in
use the memory backing the vmemmap must also be freed.

This patch adds a new remove_pagetable() helper which can be used to tear
down either region, and calls it from vmemmap_free() and
___remove_pgd_mapping(). The sparse_vmap argument determines whether the
backing memory will be freed.

remove_pagetable() makes two distinct passes over the kernel page table.
In the first pass it unmaps, invalidates applicable TLB cache and frees
backing memory if required (vmemmap) for each mapped leaf entry. In the
second pass it looks for empty page table sections whose page table page
can be unmapped, TLB invalidated and freed.

While freeing intermediate level page table pages bail out if any of its
entries are still valid. This can happen for partially filled kernel page
table either from a previously attempted failed memory hot add or while
removing an address range which does not span the entire page table page
range.

The vmemmap region may share levels of table with the vmalloc region.
There can be conflicts between hot remove freeing page table pages with
a concurrent vmalloc() walking the kernel page table. This conflict can
not just be solved by taking the init_mm ptl because of existing locking
scheme in vmalloc(). Hence unlike linear mapping, skip freeing page table
pages while tearing down vmemmap mapping.

While here update arch_add_memory() to handle __add_pages() failures by
just unmapping recently added kernel linear mapping. Now enable memory hot
remove on arm64 platforms by default with ARCH_ENABLE_MEMORY_HOTREMOVE.

This implementation is overall inspired from kernel page table tear down
procedure on X86 architecture.

Acked-by: Steve Capper <steve.capper@arm.com>
Acked-by: David Hildenbrand <david@redhat.com>
Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 arch/arm64/Kconfig  |   3 +
 arch/arm64/mm/mmu.c | 290 ++++++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 284 insertions(+), 9 deletions(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 7442edb..b94daec 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -273,6 +273,9 @@ config ZONE_DMA32
 config ARCH_ENABLE_MEMORY_HOTPLUG
 	def_bool y
 
+config ARCH_ENABLE_MEMORY_HOTREMOVE
+	def_bool y
+
 config SMP
 	def_bool y
 
diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index 750a69d..282a4b2 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -722,6 +722,250 @@ int kern_addr_valid(unsigned long addr)
 
 	return pfn_valid(pte_pfn(pte));
 }
+
+#ifdef CONFIG_MEMORY_HOTPLUG
+static void free_hotplug_page_range(struct page *page, size_t size)
+{
+	WARN_ON(!page || PageReserved(page));
+	free_pages((unsigned long)page_address(page), get_order(size));
+}
+
+static void free_hotplug_pgtable_page(struct page *page)
+{
+	free_hotplug_page_range(page, PAGE_SIZE);
+}
+
+static void free_pte_table(pmd_t *pmdp, unsigned long addr)
+{
+	struct page *page;
+	pte_t *ptep;
+	int i;
+
+	ptep = pte_offset_kernel(pmdp, 0UL);
+	for (i = 0; i < PTRS_PER_PTE; i++) {
+		if (!pte_none(READ_ONCE(ptep[i])))
+			return;
+	}
+
+	page = pmd_page(READ_ONCE(*pmdp));
+	pmd_clear(pmdp);
+	__flush_tlb_kernel_pgtable(addr);
+	free_hotplug_pgtable_page(page);
+}
+
+static void free_pmd_table(pud_t *pudp, unsigned long addr)
+{
+	struct page *page;
+	pmd_t *pmdp;
+	int i;
+
+	if (CONFIG_PGTABLE_LEVELS <= 2)
+		return;
+
+	pmdp = pmd_offset(pudp, 0UL);
+	for (i = 0; i < PTRS_PER_PMD; i++) {
+		if (!pmd_none(READ_ONCE(pmdp[i])))
+			return;
+	}
+
+	page = pud_page(READ_ONCE(*pudp));
+	pud_clear(pudp);
+	__flush_tlb_kernel_pgtable(addr);
+	free_hotplug_pgtable_page(page);
+}
+
+static void free_pud_table(pgd_t *pgdp, unsigned long addr)
+{
+	struct page *page;
+	pud_t *pudp;
+	int i;
+
+	if (CONFIG_PGTABLE_LEVELS <= 3)
+		return;
+
+	pudp = pud_offset(pgdp, 0UL);
+	for (i = 0; i < PTRS_PER_PUD; i++) {
+		if (!pud_none(READ_ONCE(pudp[i])))
+			return;
+	}
+
+	page = pgd_page(READ_ONCE(*pgdp));
+	pgd_clear(pgdp);
+	__flush_tlb_kernel_pgtable(addr);
+	free_hotplug_pgtable_page(page);
+}
+
+static void unmap_hotplug_pte_range(pmd_t *pmdp, unsigned long addr,
+				    unsigned long end, bool sparse_vmap)
+{
+	struct page *page;
+	pte_t *ptep, pte;
+
+	do {
+		ptep = pte_offset_kernel(pmdp, addr);
+		pte = READ_ONCE(*ptep);
+		if (pte_none(pte))
+			continue;
+
+		WARN_ON(!pte_present(pte));
+		page = sparse_vmap ? pte_page(pte) : NULL;
+		pte_clear(&init_mm, addr, ptep);
+		flush_tlb_kernel_range(addr, addr + PAGE_SIZE);
+		if (sparse_vmap)
+			free_hotplug_page_range(page, PAGE_SIZE);
+	} while (addr += PAGE_SIZE, addr < end);
+}
+
+static void unmap_hotplug_pmd_range(pud_t *pudp, unsigned long addr,
+				    unsigned long end, bool sparse_vmap)
+{
+	unsigned long next;
+	struct page *page;
+	pmd_t *pmdp, pmd;
+
+	do {
+		next = pmd_addr_end(addr, end);
+		pmdp = pmd_offset(pudp, addr);
+		pmd = READ_ONCE(*pmdp);
+		if (pmd_none(pmd))
+			continue;
+
+		WARN_ON(!pmd_present(pmd));
+		if (pmd_sect(pmd)) {
+			page = sparse_vmap ? pmd_page(pmd) : NULL;
+			pmd_clear(pmdp);
+			flush_tlb_kernel_range(addr, next);
+			if (sparse_vmap)
+				free_hotplug_page_range(page, PMD_SIZE);
+			continue;
+		}
+		WARN_ON(!pmd_table(pmd));
+		unmap_hotplug_pte_range(pmdp, addr, next, sparse_vmap);
+	} while (addr = next, addr < end);
+}
+
+static void unmap_hotplug_pud_range(pgd_t *pgdp, unsigned long addr,
+				    unsigned long end, bool sparse_vmap)
+{
+	unsigned long next;
+	struct page *page;
+	pud_t *pudp, pud;
+
+	do {
+		next = pud_addr_end(addr, end);
+		pudp = pud_offset(pgdp, addr);
+		pud = READ_ONCE(*pudp);
+		if (pud_none(pud))
+			continue;
+
+		WARN_ON(!pud_present(pud));
+		if (pud_sect(pud)) {
+			page = sparse_vmap ? pud_page(pud) : NULL;
+			pud_clear(pudp);
+			flush_tlb_kernel_range(addr, next);
+			if (sparse_vmap)
+				free_hotplug_page_range(page, PUD_SIZE);
+			continue;
+		}
+		WARN_ON(!pud_table(pud));
+		unmap_hotplug_pmd_range(pudp, addr, next, sparse_vmap);
+	} while (addr = next, addr < end);
+}
+
+static void unmap_hotplug_range(unsigned long addr, unsigned long end,
+				bool sparse_vmap)
+{
+	unsigned long next;
+	pgd_t *pgdp, pgd;
+
+	do {
+		next = pgd_addr_end(addr, end);
+		pgdp = pgd_offset_k(addr);
+		pgd = READ_ONCE(*pgdp);
+		if (pgd_none(pgd))
+			continue;
+
+		WARN_ON(!pgd_present(pgd));
+		unmap_hotplug_pud_range(pgdp, addr, next, sparse_vmap);
+	} while (addr = next, addr < end);
+}
+
+static void free_empty_pte_table(pmd_t *pmdp, unsigned long addr,
+				 unsigned long end)
+{
+	pte_t *ptep, pte;
+
+	do {
+		ptep = pte_offset_kernel(pmdp, addr);
+		pte = READ_ONCE(*ptep);
+		WARN_ON(!pte_none(pte));
+	} while (addr += PAGE_SIZE, addr < end);
+}
+
+static void free_empty_pmd_table(pud_t *pudp, unsigned long addr,
+				 unsigned long end)
+{
+	unsigned long next;
+	pmd_t *pmdp, pmd;
+
+	do {
+		next = pmd_addr_end(addr, end);
+		pmdp = pmd_offset(pudp, addr);
+		pmd = READ_ONCE(*pmdp);
+		if (pmd_none(pmd))
+			continue;
+
+		WARN_ON(!pmd_present(pmd) || !pmd_table(pmd) || pmd_sect(pmd));
+		free_empty_pte_table(pmdp, addr, next);
+		free_pte_table(pmdp, addr);
+	} while (addr = next, addr < end);
+}
+
+static void free_empty_pud_table(pgd_t *pgdp, unsigned long addr,
+				 unsigned long end)
+{
+	unsigned long next;
+	pud_t *pudp, pud;
+
+	do {
+		next = pud_addr_end(addr, end);
+		pudp = pud_offset(pgdp, addr);
+		pud = READ_ONCE(*pudp);
+		if (pud_none(pud))
+			continue;
+
+		WARN_ON(!pud_present(pud) || !pud_table(pud) || pud_sect(pud));
+		free_empty_pmd_table(pudp, addr, next);
+		free_pmd_table(pudp, addr);
+	} while (addr = next, addr < end);
+}
+
+static void free_empty_tables(unsigned long addr, unsigned long end)
+{
+	unsigned long next;
+	pgd_t *pgdp, pgd;
+
+	do {
+		next = pgd_addr_end(addr, end);
+		pgdp = pgd_offset_k(addr);
+		pgd = READ_ONCE(*pgdp);
+		if (pgd_none(pgd))
+			continue;
+
+		WARN_ON(!pgd_present(pgd));
+		free_empty_pud_table(pgdp, addr, next);
+		free_pud_table(pgdp, addr);
+	} while (addr = next, addr < end);
+}
+
+static void remove_pagetable(unsigned long start, unsigned long end,
+			     bool sparse_vmap)
+{
+	unmap_hotplug_range(start, end, sparse_vmap);
+	free_empty_tables(start, end);
+}
+#endif
+
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
 #if !ARM64_SWAPPER_USES_SECTION_MAPS
 int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
@@ -769,6 +1013,27 @@ int __meminit vmemmap_populate(unsigned long start, unsigned long end, int node,
 void vmemmap_free(unsigned long start, unsigned long end,
 		struct vmem_altmap *altmap)
 {
+#ifdef CONFIG_MEMORY_HOTPLUG
+	/*
+	 * FIXME: We should have called remove_pagetable(start, end, true).
+	 * vmemmap and vmalloc virtual range might share intermediate kernel
+	 * page table entries. Removing vmemmap range page table pages here
+	 * can potentially conflict with a concurrent vmalloc() allocation.
+	 *
+	 * This is primarily because vmalloc() does not take init_mm ptl for
+	 * the entire page table walk and it's modification. Instead it just
+	 * takes the lock while allocating and installing page table pages
+	 * via [p4d|pud|pmd|pte]_alloc(). A concurrently vanishing page table
+	 * entry via memory hot remove can cause vmalloc() kernel page table
+	 * walk pointers to be invalid on the fly which can cause corruption
+	 * or worst, a crash.
+	 *
+	 * To avoid this problem, lets not free empty page table pages for
+	 * given vmemmap range being hot-removed. Just unmap and free the
+	 * range instead.
+	 */
+	unmap_hotplug_range(start, end, true);
+#endif
 }
 #endif	/* CONFIG_SPARSEMEM_VMEMMAP */
 
@@ -1060,10 +1325,18 @@ int p4d_free_pud_page(p4d_t *p4d, unsigned long addr)
 }
 
 #ifdef CONFIG_MEMORY_HOTPLUG
+static void __remove_pgd_mapping(pgd_t *pgdir, unsigned long start, u64 size)
+{
+	unsigned long end = start + size;
+
+	WARN_ON(pgdir != init_mm.pgd);
+	remove_pagetable(start, end, false);
+}
+
 int arch_add_memory(int nid, u64 start, u64 size,
 			struct mhp_restrictions *restrictions)
 {
-	int flags = 0;
+	int ret, flags = 0;
 
 	if (rodata_full || debug_pagealloc_enabled())
 		flags = NO_BLOCK_MAPPINGS | NO_CONT_MAPPINGS;
@@ -1071,9 +1344,14 @@ int arch_add_memory(int nid, u64 start, u64 size,
 	__create_pgd_mapping(swapper_pg_dir, start, __phys_to_virt(start),
 			     size, PAGE_KERNEL, __pgd_pgtable_alloc, flags);
 
-	return __add_pages(nid, start >> PAGE_SHIFT, size >> PAGE_SHIFT,
+	ret = __add_pages(nid, start >> PAGE_SHIFT, size >> PAGE_SHIFT,
 			   restrictions);
+	if (ret)
+		__remove_pgd_mapping(swapper_pg_dir,
+				     __phys_to_virt(start), size);
+	return ret;
 }
+
 void arch_remove_memory(int nid, u64 start, u64 size,
 			struct vmem_altmap *altmap)
 {
@@ -1081,14 +1359,8 @@ void arch_remove_memory(int nid, u64 start, u64 size,
 	unsigned long nr_pages = size >> PAGE_SHIFT;
 	struct zone *zone;
 
-	/*
-	 * FIXME: Cleanup page tables (also in arch_add_memory() in case
-	 * adding fails). Until then, this function should only be used
-	 * during memory hotplug (adding memory), not for memory
-	 * unplug. ARCH_ENABLE_MEMORY_HOTREMOVE must not be
-	 * unlocked yet.
-	 */
 	zone = page_zone(pfn_to_page(start_pfn));
 	__remove_pages(zone, start_pfn, nr_pages, altmap);
+	__remove_pgd_mapping(swapper_pg_dir, __phys_to_virt(start), size);
 }
 #endif
-- 
2.7.4

