Return-Path: <SRS0=UfqE=T4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3420EC04AB6
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 12:09:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DDDAC2081C
	for <linux-mm@archiver.kernel.org>; Tue, 28 May 2019 12:09:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kQuK0GsL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DDDAC2081C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5DFE96B0278; Tue, 28 May 2019 08:09:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 58FA16B0279; Tue, 28 May 2019 08:09:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4576D6B027A; Tue, 28 May 2019 08:09:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0A0296B0278
	for <linux-mm@kvack.org>; Tue, 28 May 2019 08:09:11 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id d7so13856871pgc.8
        for <linux-mm@kvack.org>; Tue, 28 May 2019 05:09:11 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=pn8fi/WvUvwUzQoGGlsgS4xe4epAAh2bTKX49ROjLQ4=;
        b=K9qVmigxzYpAOuVkKM2y/lL/RGwZJasb9MwR9ibzqzTomnIY/0xTJ/rmnCHM7OhyGt
         FNiiN39l89tEtbM8z0M8Lui226ADSnsBrMWwMAiVGDayiBlQ2V1H2TSv1kQv6x8kEYqC
         nEMKMk+eGMKKKGp9Fdd4jgWiieSksfRkS+fPJ2G9dcUMNHgGuahHdGFfYXxeG1QOiQSv
         rp7Uq1gJIbncfDcWvFnDrPdfG7zHvwX69N+e0QV+TELRFa2CX18sXkOom4/NcZAOp/25
         BeqxquvlCFs5q9lY9egtPCwHOR4+E7ih+Kqp+R7UqHbZ6CMjEC6WYJkZcRJ/AbvNRL4X
         ol4Q==
X-Gm-Message-State: APjAAAUu9HTYpTVDfFpJh2RBp1zWrehhF53NHr5V9NKK3IuyW3cDb6p/
	ifHelgv8WFGepbdXQevZdBilbTF2SdYLrK6h6m+LDp/+sO8cCcTVzYMdjZhCIPxibAfz+U0mL3Z
	nddYhbvds+QRyNEW83hO0ohGO5EaWdMx+MutCYl9Rk/Kt1rPC3TKtbGFxFSsPyVwJiQ==
X-Received: by 2002:a17:90a:ac18:: with SMTP id o24mr5644884pjq.116.1559045350669;
        Tue, 28 May 2019 05:09:10 -0700 (PDT)
X-Received: by 2002:a17:90a:ac18:: with SMTP id o24mr5644679pjq.116.1559045349125;
        Tue, 28 May 2019 05:09:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559045349; cv=none;
        d=google.com; s=arc-20160816;
        b=SLmEQDkKGbMkmrCVOpQYz5lM9lQxEwbHD3joN0RoUPm7z+c81fqThVn7dim6tTeJMN
         ctSosLorGadJ2yV7wwaFgTiwUR7Pu43sfByz2epcjiqNedVBZr1BTZ8smRo86bOxluEN
         I9ZwXbEp0FtFtztOlMKDPf+15VjI60On5Vxtfk51IFTC/YVT6hA4Wrc4zzuCuOkerjUB
         ttghvOOkNE2n+tDep3hE2lGb7niUkoZ03xA8uNI4D9OHI/a+J2IU/qKrCXqQKEk7q7SK
         g2g3gednM8GG+Bqo5Gnm6rAU42FULmjO5bmc+WTeVedGAzWTKTYYHZpWuBXcXh78cFY4
         E/xw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=pn8fi/WvUvwUzQoGGlsgS4xe4epAAh2bTKX49ROjLQ4=;
        b=pdfoy4UpK2LIk5tO0H1gmBIsuvtmoGkIAqA8R2GEObD64R+Nq9izWnr4sS4Xt9mxi9
         B6tfhuDJxSEPQGXrLwyf8fMUIVMrDEi97QjXekym/W9rOjszlcCWMsbWhCokl1dQDwGF
         7wG7w9y5NzwLcb/KxIQ1Tz8S9JQjVOWeYgw97mm9Eg6p63TDNWRDagsMTAG7Yzh2C6et
         k/HMLddLMDDxKUxO10aPbbOVaHT5/0FSkr2by9IGuEh/9ZOpDCTDKd7CybT0rrXaqNTx
         9uB8/rwlmc7tRjqIXc/sBWGtLO349FjNLpJ4CRh6W0MMwSUgB7MtGY9tOK1zh4BDJRM/
         2TJw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kQuK0GsL;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g9sor2850006pjs.21.2019.05.28.05.09.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 May 2019 05:09:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=kQuK0GsL;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=pn8fi/WvUvwUzQoGGlsgS4xe4epAAh2bTKX49ROjLQ4=;
        b=kQuK0GsL2qZ3B7V5vIm06V1Vk0l7UnVYud20vsF5lcp2Y8Ko/hWCUnMXgVg+sFXR45
         vhrHZIstmTyxX7S4xovwvpwYnRbDNAX+IKF8bdjLXMwxn3+FLbHl5/JWxVfD9gbgwZSW
         JEHBsv5SI1oQOHu01fX8wsCpwWaBaey3gr5KfTfyh8t4h2h0P25agpmKNRGJBp/7S6uQ
         Jrl+qmsPqe1mcqnr7UocDzuwECcNoLqgLty6y+HXHKTvBVCpkszTiDM93wvxG3dLNUiH
         dGs6fppKQtGA/LiearoRWYlsuw97Ebr/D1CQULJgTrIXvxeCNgJzrQgjzviHsHhVJYyq
         kVsA==
X-Google-Smtp-Source: APXvYqwW3TeLO4TumFfGqy7Cf/75OHM0IJhVhfngPf1gbu23C7jk4UR4wjogQvLODkbxFfASiCS4tA==
X-Received: by 2002:a17:90a:b393:: with SMTP id e19mr5563477pjr.91.1559045348550;
        Tue, 28 May 2019 05:09:08 -0700 (PDT)
Received: from bobo.local0.net (193-116-79-40.tpgi.com.au. [193.116.79.40])
        by smtp.gmail.com with ESMTPSA id d15sm37463327pfm.186.2019.05.28.05.09.04
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 May 2019 05:09:07 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
To: linux-mm@kvack.org
Cc: Nicholas Piggin <npiggin@gmail.com>,
	linux-arch@vger.kernel.org,
	Toshi Kani <toshi.kani@hp.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Uladzislau Rezki <urezki@gmail.com>
Subject: [PATCH 4/4] mm/vmalloc: Hugepage vmalloc mappings
Date: Tue, 28 May 2019 22:04:53 +1000
Message-Id: <20190528120453.27374-4-npiggin@gmail.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190528120453.27374-1-npiggin@gmail.com>
References: <20190528120453.27374-1-npiggin@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

For platforms that define HAVE_ARCH_HUGE_VMAP, have vmalloc try to
allocate and map PMD-level huge pages when size is appropriate, and
fallback if unsuccessful.

Using 2MB page mappings in an 8MB dentry cache hash brings dTLB misses
for linux kernel tree `git diff` from 45,000 to 8,000 on a Kaby Lake CPU
wth mitigations=off (performance is in the noise, under 1% difference,
page tables are likely to be well cached for this workload).

Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
---
 include/linux/vmalloc.h |   1 +
 mm/vmalloc.c            | 132 +++++++++++++++++++++++++++++++---------
 2 files changed, 105 insertions(+), 28 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 812bea5866d6..4c92dc608928 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -42,6 +42,7 @@ struct vm_struct {
 	unsigned long		size;
 	unsigned long		flags;
 	struct page		**pages;
+	unsigned int		page_shift;
 	unsigned int		nr_pages;
 	phys_addr_t		phys_addr;
 	const void		*caller;
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 6a0c97f89091..34de925ed4f4 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -36,6 +36,7 @@
 #include <linux/rbtree_augmented.h>
 
 #include <linux/uaccess.h>
+#include <asm/pgtable.h>
 #include <asm/tlbflush.h>
 #include <asm/shmparam.h>
 
@@ -439,6 +440,41 @@ static int vmap_pages_range(unsigned long start, unsigned long end,
 	return ret;
 }
 
+#ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
+static int vmap_hpages_range(unsigned long start, unsigned long end,
+				   pgprot_t prot, struct page **pages,
+				   unsigned int page_shift)
+{
+	unsigned long addr = start;
+	unsigned int i, nr = (end - start) >> (PAGE_SHIFT + page_shift);
+
+	for (i = 0; i < nr; i++) {
+		int err;
+
+		err = vmap_range_noflush(addr,
+					addr + (PAGE_SIZE << page_shift),
+					__pa(page_address(pages[i])), prot,
+					page_shift);
+		if (err)
+			return err;
+
+		addr += PAGE_SIZE << page_shift;
+	}
+	flush_cache_vmap(start, end);
+
+	return nr;
+}
+#else
+static int vmap_hpages_range(unsigned long start, unsigned long end,
+			   pgprot_t prot, struct page **pages,
+			   unsigned int page_shift)
+{
+	BUG_ON(page_shift != PAGE_SIZE);
+	return vmap_pages_range(start, end, prot, pages);
+}
+#endif
+
+
 int is_vmalloc_or_module_addr(const void *x)
 {
 	/*
@@ -461,7 +497,7 @@ struct page *vmalloc_to_page(const void *vmalloc_addr)
 {
 	unsigned long addr = (unsigned long) vmalloc_addr;
 	struct page *page = NULL;
-	pgd_t *pgd = pgd_offset_k(addr);
+	pgd_t *pgd;
 	p4d_t *p4d;
 	pud_t *pud;
 	pmd_t *pmd;
@@ -473,27 +509,38 @@ struct page *vmalloc_to_page(const void *vmalloc_addr)
 	 */
 	VIRTUAL_BUG_ON(!is_vmalloc_or_module_addr(vmalloc_addr));
 
+	pgd = pgd_offset_k(addr);
 	if (pgd_none(*pgd))
 		return NULL;
+
 	p4d = p4d_offset(pgd, addr);
 	if (p4d_none(*p4d))
 		return NULL;
-	pud = pud_offset(p4d, addr);
+#ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
+	if (p4d_large(*p4d))
+		return p4d_page(*p4d) + ((addr & ~P4D_MASK) >> PAGE_SHIFT);
+#endif
+	if (WARN_ON_ONCE(p4d_bad(*p4d)))
+		return NULL;
 
-	/*
-	 * Don't dereference bad PUD or PMD (below) entries. This will also
-	 * identify huge mappings, which we may encounter on architectures
-	 * that define CONFIG_HAVE_ARCH_HUGE_VMAP=y. Such regions will be
-	 * identified as vmalloc addresses by is_vmalloc_addr(), but are
-	 * not [unambiguously] associated with a struct page, so there is
-	 * no correct value to return for them.
-	 */
-	WARN_ON_ONCE(pud_bad(*pud));
-	if (pud_none(*pud) || pud_bad(*pud))
+	pud = pud_offset(p4d, addr);
+	if (pud_none(*pud))
+		return NULL;
+#ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
+	if (pud_large(*pud))
+		return pud_page(*pud) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
+#endif
+	if (WARN_ON_ONCE(pud_bad(*pud)))
 		return NULL;
+
 	pmd = pmd_offset(pud, addr);
-	WARN_ON_ONCE(pmd_bad(*pmd));
-	if (pmd_none(*pmd) || pmd_bad(*pmd))
+	if (pmd_none(*pmd))
+		return NULL;
+#ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
+	if (pmd_large(*pmd))
+		return pmd_page(*pmd) + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
+#endif
+	if (WARN_ON_ONCE(pmd_bad(*pmd)))
 		return NULL;
 
 	ptep = pte_offset_map(pmd, addr);
@@ -501,6 +548,7 @@ struct page *vmalloc_to_page(const void *vmalloc_addr)
 	if (pte_present(pte))
 		page = pte_page(pte);
 	pte_unmap(ptep);
+
 	return page;
 }
 EXPORT_SYMBOL(vmalloc_to_page);
@@ -2184,8 +2232,9 @@ static struct vm_struct *__get_vm_area_node(unsigned long size,
 		return NULL;
 
 	if (flags & VM_IOREMAP)
-		align = 1ul << clamp_t(int, get_count_order_long(size),
-				       PAGE_SHIFT, IOREMAP_MAX_ORDER);
+		align = max(align,
+				1ul << clamp_t(int, get_count_order_long(size),
+				       PAGE_SHIFT, IOREMAP_MAX_ORDER));
 
 	area = kzalloc_node(sizeof(*area), gfp_mask & GFP_RECLAIM_MASK, node);
 	if (unlikely(!area))
@@ -2397,7 +2446,7 @@ static void __vunmap(const void *addr, int deallocate_pages)
 			struct page *page = area->pages[i];
 
 			BUG_ON(!page);
-			__free_pages(page, 0);
+			__free_pages(page, area->page_shift);
 		}
 
 		kvfree(area->pages);
@@ -2540,14 +2589,17 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 				 pgprot_t prot, int node)
 {
 	struct page **pages;
+	unsigned long addr = (unsigned long)area->addr;
+	unsigned long size = get_vm_area_size(area);
+	unsigned int page_shift = area->page_shift;
+	unsigned int shift = page_shift + PAGE_SHIFT;
 	unsigned int nr_pages, array_size, i;
 	const gfp_t nested_gfp = (gfp_mask & GFP_RECLAIM_MASK) | __GFP_ZERO;
 	const gfp_t alloc_mask = gfp_mask | __GFP_NOWARN;
 	const gfp_t highmem_mask = (gfp_mask & (GFP_DMA | GFP_DMA32)) ?
-					0 :
-					__GFP_HIGHMEM;
+					0 : __GFP_HIGHMEM;
 
-	nr_pages = get_vm_area_size(area) >> PAGE_SHIFT;
+	nr_pages = size >> shift;
 	array_size = (nr_pages * sizeof(struct page *));
 
 	area->nr_pages = nr_pages;
@@ -2568,10 +2620,8 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 	for (i = 0; i < area->nr_pages; i++) {
 		struct page *page;
 
-		if (node == NUMA_NO_NODE)
-			page = alloc_page(alloc_mask|highmem_mask);
-		else
-			page = alloc_pages_node(node, alloc_mask|highmem_mask, 0);
+		page = alloc_pages_node(node,
+				alloc_mask|highmem_mask, page_shift);
 
 		if (unlikely(!page)) {
 			/* Successfully allocated i pages, free them in __vunmap() */
@@ -2583,8 +2633,9 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 			cond_resched();
 	}
 
-	if (map_vm_area(area, prot, pages))
+	if (vmap_hpages_range(addr, addr + size, prot, pages, page_shift) < 0)
 		goto fail;
+
 	return area->addr;
 
 fail:
@@ -2618,22 +2669,39 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
 			pgprot_t prot, unsigned long vm_flags, int node,
 			const void *caller)
 {
-	struct vm_struct *area;
+	struct vm_struct *area = NULL;
 	void *addr;
 	unsigned long real_size = size;
+	unsigned long real_align = align;
+	unsigned int shift = PAGE_SHIFT;
 
 	size = PAGE_ALIGN(size);
 	if (!size || (size >> PAGE_SHIFT) > totalram_pages())
 		goto fail;
 
+	if (IS_ENABLED(CONFIG_HAVE_ARCH_HUGE_VMAP)) {
+		unsigned long size_per_node;
+
+		size_per_node = size;
+		if (node == NUMA_NO_NODE)
+			size_per_node /= num_online_nodes();
+		if (size_per_node >= PMD_SIZE)
+			shift = PMD_SHIFT;
+	}
+again:
+	align = max(real_align, 1UL << shift);
+	size = ALIGN(real_size, align);
+
 	area = __get_vm_area_node(size, align, VM_ALLOC | VM_UNINITIALIZED |
 				vm_flags, start, end, node, gfp_mask, caller);
 	if (!area)
 		goto fail;
 
+	area->page_shift = shift - PAGE_SHIFT;
+
 	addr = __vmalloc_area_node(area, gfp_mask, prot, node);
 	if (!addr)
-		return NULL;
+		goto fail;
 
 	/*
 	 * In this function, newly allocated vm_struct has VM_UNINITIALIZED
@@ -2647,8 +2715,16 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
 	return addr;
 
 fail:
-	warn_alloc(gfp_mask, NULL,
+	if (shift == PMD_SHIFT) {
+		shift = PAGE_SHIFT;
+		goto again;
+	}
+
+	if (!area) {
+		/* Warn for area allocation, page allocations already warn */
+		warn_alloc(gfp_mask, NULL,
 			  "vmalloc: allocation failure: %lu bytes", real_size);
+	}
 	return NULL;
 }
 
-- 
2.20.1

