Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7DED2C10F00
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 10:33:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2166220818
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 10:33:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="TyETKWS0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2166220818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AD8148E0012; Tue, 19 Feb 2019 05:33:07 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A64D18E000F; Tue, 19 Feb 2019 05:33:07 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8DEF48E0012; Tue, 19 Feb 2019 05:33:07 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5781D8E000F
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 05:33:07 -0500 (EST)
Received: by mail-it1-f200.google.com with SMTP id x9so3661615ite.1
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 02:33:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:user-agent:date:from
         :to:cc:subject:references:mime-version;
        bh=ngbrIENLEkIPPxOXSmPjRwnweo/SdtFjhtblxd03rZA=;
        b=YyJtHf0WTXlK204U6e6rVx493W18bpDVhIo5Op1katA1G1crCRy+94qLhW0UW5foF9
         buVgIs0ZdOMXp/4kjT2q9MZWn6Su79gLFeqFBVWjcD8aN4AekFe0wViPfU114sfh6V6z
         9H6gEp0Au9Y9vMRVsRxNwGyELA+KZRU7Okl3Dh4i99ISj0oS63HAd+YrAY85e1L9+BBA
         GrYU6hvHZVxHqwZAZ5OO/H5OG/5zN1lV1lXARZAgAh535yvSp0hPga7sbu0AS3gt+iyN
         CQgoThEWuhUkAtn7IywysqzmS3/K8d+qBEXmfuXl+Bkp1b+rqn+7SnVoxJN4phQCkRe+
         f6jQ==
X-Gm-Message-State: AHQUAuYAhG2ATfSK7LnzgGFrHojaOTwbEOZ0XifVPzHUAGHYQG/GBl1R
	188rdgES09cT6H4AUdaa/OHShTQh4vR/5uuO/Xv4xxMwFJGphhq5EnLP1qDGDohn3oRasJrAeku
	0w2ZVxU2xuMKSKg0ASgGHZt/ftLwkh5cwL8HWTSfH/ECni9+7Ihz/ud0PF+kGygC5BQ==
X-Received: by 2002:a05:660c:a50:: with SMTP id j16mr1627542itl.52.1550572387002;
        Tue, 19 Feb 2019 02:33:07 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbnjDqkLGGsyG8dOzVPv5GWkD152NiCiLo5WgEdhlFkg6+2APuHev7BWubTMMasqCoOKF1r
X-Received: by 2002:a05:660c:a50:: with SMTP id j16mr1627501itl.52.1550572385831;
        Tue, 19 Feb 2019 02:33:05 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550572385; cv=none;
        d=google.com; s=arc-20160816;
        b=mDh+ykGv2vpoMknTkWl8WGC89wr0NACHJahpUAXaD6YsuMRgVucwqjqZU9cYsQ4f/Q
         j3Ux54FXaa5kY65j8VmV4jWNtbaYvNEvjMHFpevYOrh0wxijTHIdHk4XsMJbfML+Pu/d
         a7RQ3jhhfUdCX0y32xxB/7ww3sT8m7bBOPNMO+1jPFWiWs+sv//T873ZJxRY8pT6OSc3
         WDK+iYAzRbG/urDZxMTWEr+UKcFQIZELpPmBju0qIoa877hNqYWY7mTWGA7MOu1qIVOh
         95jBngJr36lcs3g5eCzR5l7fHeR2YnWEzHk+yG6rWYJsZqq29dKfcyKslqbSYso/vq6X
         s6OQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id:dkim-signature;
        bh=ngbrIENLEkIPPxOXSmPjRwnweo/SdtFjhtblxd03rZA=;
        b=gkcpTJDOiabmbEMlVJdCK1Onmi3h3KMqO8GUeQJMU4HjxH8KOZZy7WIzMff5LflV/c
         qKna0n6wHZoaRI3EN2cZr+ntC5jCXPRZCflUr0deGpxQhjZr4JKcFX0+7tDO3OMry3Zn
         AJNuaPi8E908fEijsmO7LIOe++sGhKWEONXHvYYuL7NUOzzEI1pFdRUgSUT4ff1yoyrA
         cb+VrtirM7yP+zrQg4CxZeScu2n+1iZFWHZiJXkRC75/63AnK9tz5TXco+n2cGUgH4t6
         ApSkq6jgYGR/ZYc1NaYiiTjLaK1+dke9KK7T18zsAuCOxnJ2cARkBley8lnrdUKTrWhv
         F8LA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=TyETKWS0;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id b9si1093638itb.70.2019.02.19.02.33.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 02:33:05 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=TyETKWS0;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Type:MIME-Version:References:
	Subject:Cc:To:From:Date:Message-Id:Sender:Reply-To:Content-Transfer-Encoding:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=ngbrIENLEkIPPxOXSmPjRwnweo/SdtFjhtblxd03rZA=; b=TyETKWS0DUK5QCP92085hwCNy8
	dcVfiCc7jIIw+gEqb+Cl1ALjCmnCDTYWxsBnrg1pLEByjBbJZ77pwljdv04kPeX7tAWlm4awIj2vJ
	tyeEgNA7Z5daYxoltiV41EgJScfILhhGaGBN5X4Woz/dG5bqNtoxmDkC4kZOVl+t3hPwlaGOh45bh
	rEELKj60dwJfl0VxaKyYKtAmPkVTJg2TNEEWZ7Yg9VPQee1HsIOLM2B1VIW0xtMClNGVdH5pdjqyk
	cmQhyOrtLJEIIkSb76wTzgUM22xQk8IBh96HisskAU1aXzkg97D2+O4pGsdJpQLsc54qi+GWXCgly
	HJ+vC/vA==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gw2hn-0000dl-IV; Tue, 19 Feb 2019 10:32:52 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 0)
	id 63F1A2852059C; Tue, 19 Feb 2019 11:32:48 +0100 (CET)
Message-Id: <20190219103233.383087152@infradead.org>
User-Agent: quilt/0.65
Date: Tue, 19 Feb 2019 11:31:57 +0100
From: Peter Zijlstra <peterz@infradead.org>
To: will.deacon@arm.com,
 aneesh.kumar@linux.vnet.ibm.com,
 akpm@linux-foundation.org,
 npiggin@gmail.com
Cc: linux-arch@vger.kernel.org,
 linux-mm@kvack.org,
 linux-kernel@vger.kernel.org,
 peterz@infradead.org,
 linux@armlinux.org.uk,
 heiko.carstens@de.ibm.com,
 riel@surriel.com,
 Tony Luck <tony.luck@intel.com>
Subject: [PATCH v6 09/18] ia64/tlb: Conver to generic mmu_gather
References: <20190219103148.192029670@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Generic mmu_gather provides everything ia64 needs (range tracking).

Cc: Will Deacon <will.deacon@arm.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@gmail.com>
Cc: Tony Luck <tony.luck@intel.com>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/ia64/include/asm/tlb.h      |  256 ---------------------------------------
 arch/ia64/include/asm/tlbflush.h |   25 +++
 arch/ia64/mm/tlb.c               |   23 +++
 3 files changed, 47 insertions(+), 257 deletions(-)

--- a/arch/ia64/include/asm/tlb.h
+++ b/arch/ia64/include/asm/tlb.h
@@ -47,262 +47,8 @@
 #include <asm/tlbflush.h>
 #include <asm/machvec.h>
 
-/*
- * If we can't allocate a page to make a big batch of page pointers
- * to work on, then just handle a few from the on-stack structure.
- */
-#define	IA64_GATHER_BUNDLE	8
-
-struct mmu_gather {
-	struct mm_struct	*mm;
-	unsigned int		nr;
-	unsigned int		max;
-	unsigned char		fullmm;		/* non-zero means full mm flush */
-	unsigned char		need_flush;	/* really unmapped some PTEs? */
-	unsigned long		start, end;
-	unsigned long		start_addr;
-	unsigned long		end_addr;
-	struct page		**pages;
-	struct page		*local[IA64_GATHER_BUNDLE];
-};
-
-struct ia64_tr_entry {
-	u64 ifa;
-	u64 itir;
-	u64 pte;
-	u64 rr;
-}; /*Record for tr entry!*/
-
-extern int ia64_itr_entry(u64 target_mask, u64 va, u64 pte, u64 log_size);
-extern void ia64_ptr_entry(u64 target_mask, int slot);
-
-extern struct ia64_tr_entry *ia64_idtrs[NR_CPUS];
-
-/*
- region register macros
-*/
-#define RR_TO_VE(val)   (((val) >> 0) & 0x0000000000000001)
-#define RR_VE(val)	(((val) & 0x0000000000000001) << 0)
-#define RR_VE_MASK	0x0000000000000001L
-#define RR_VE_SHIFT	0
-#define RR_TO_PS(val)	(((val) >> 2) & 0x000000000000003f)
-#define RR_PS(val)	(((val) & 0x000000000000003f) << 2)
-#define RR_PS_MASK	0x00000000000000fcL
-#define RR_PS_SHIFT	2
-#define RR_RID_MASK	0x00000000ffffff00L
-#define RR_TO_RID(val) 	((val >> 8) & 0xffffff)
-
-static inline void
-ia64_tlb_flush_mmu_tlbonly(struct mmu_gather *tlb, unsigned long start, unsigned long end)
-{
-	tlb->need_flush = 0;
-
-	if (tlb->fullmm) {
-		/*
-		 * Tearing down the entire address space.  This happens both as a result
-		 * of exit() and execve().  The latter case necessitates the call to
-		 * flush_tlb_mm() here.
-		 */
-		flush_tlb_mm(tlb->mm);
-	} else if (unlikely (end - start >= 1024*1024*1024*1024UL
-			     || REGION_NUMBER(start) != REGION_NUMBER(end - 1)))
-	{
-		/*
-		 * If we flush more than a tera-byte or across regions, we're probably
-		 * better off just flushing the entire TLB(s).  This should be very rare
-		 * and is not worth optimizing for.
-		 */
-		flush_tlb_all();
-	} else {
-		/*
-		 * flush_tlb_range() takes a vma instead of a mm pointer because
-		 * some architectures want the vm_flags for ITLB/DTLB flush.
-		 */
-		struct vm_area_struct vma = TLB_FLUSH_VMA(tlb->mm, 0);
-
-		/* flush the address range from the tlb: */
-		flush_tlb_range(&vma, start, end);
-		/* now flush the virt. page-table area mapping the address range: */
-		flush_tlb_range(&vma, ia64_thash(start), ia64_thash(end));
-	}
-
-}
-
-static inline void
-ia64_tlb_flush_mmu_free(struct mmu_gather *tlb)
-{
-	unsigned long i;
-	unsigned int nr;
-
-	/* lastly, release the freed pages */
-	nr = tlb->nr;
-
-	tlb->nr = 0;
-	tlb->start_addr = ~0UL;
-	for (i = 0; i < nr; ++i)
-		free_page_and_swap_cache(tlb->pages[i]);
-}
-
-/*
- * Flush the TLB for address range START to END and, if not in fast mode, release the
- * freed pages that where gathered up to this point.
- */
-static inline void
-ia64_tlb_flush_mmu (struct mmu_gather *tlb, unsigned long start, unsigned long end)
-{
-	if (!tlb->need_flush)
-		return;
-	ia64_tlb_flush_mmu_tlbonly(tlb, start, end);
-	ia64_tlb_flush_mmu_free(tlb);
-}
-
-static inline void __tlb_alloc_page(struct mmu_gather *tlb)
-{
-	unsigned long addr = __get_free_pages(GFP_NOWAIT | __GFP_NOWARN, 0);
-
-	if (addr) {
-		tlb->pages = (void *)addr;
-		tlb->max = PAGE_SIZE / sizeof(void *);
-	}
-}
-
-
-static inline void
-arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
-			unsigned long start, unsigned long end)
-{
-	tlb->mm = mm;
-	tlb->max = ARRAY_SIZE(tlb->local);
-	tlb->pages = tlb->local;
-	tlb->nr = 0;
-	tlb->fullmm = !(start | (end+1));
-	tlb->start = start;
-	tlb->end = end;
-	tlb->start_addr = ~0UL;
-}
-
-/*
- * Called at the end of the shootdown operation to free up any resources that were
- * collected.
- */
-static inline void
-arch_tlb_finish_mmu(struct mmu_gather *tlb,
-			unsigned long start, unsigned long end, bool force)
-{
-	if (force)
-		tlb->need_flush = 1;
-	/*
-	 * Note: tlb->nr may be 0 at this point, so we can't rely on tlb->start_addr and
-	 * tlb->end_addr.
-	 */
-	ia64_tlb_flush_mmu(tlb, start, end);
-
-	/* keep the page table cache within bounds */
-	check_pgt_cache();
-
-	if (tlb->pages != tlb->local)
-		free_pages((unsigned long)tlb->pages, 0);
-}
-
-/*
- * Logically, this routine frees PAGE.  On MP machines, the actual freeing of the page
- * must be delayed until after the TLB has been flushed (see comments at the beginning of
- * this file).
- */
-static inline bool __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
-{
-	tlb->need_flush = 1;
-
-	if (!tlb->nr && tlb->pages == tlb->local)
-		__tlb_alloc_page(tlb);
-
-	tlb->pages[tlb->nr++] = page;
-	VM_WARN_ON(tlb->nr > tlb->max);
-	if (tlb->nr == tlb->max)
-		return true;
-	return false;
-}
-
-static inline void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
-{
-	ia64_tlb_flush_mmu_tlbonly(tlb, tlb->start_addr, tlb->end_addr);
-}
-
-static inline void tlb_flush_mmu_free(struct mmu_gather *tlb)
-{
-	ia64_tlb_flush_mmu_free(tlb);
-}
-
-static inline void tlb_flush_mmu(struct mmu_gather *tlb)
-{
-	ia64_tlb_flush_mmu(tlb, tlb->start_addr, tlb->end_addr);
-}
-
-static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
-{
-	if (__tlb_remove_page(tlb, page))
-		tlb_flush_mmu(tlb);
-}
-
-static inline bool __tlb_remove_page_size(struct mmu_gather *tlb,
-					  struct page *page, int page_size)
-{
-	return __tlb_remove_page(tlb, page);
-}
-
-static inline void tlb_remove_page_size(struct mmu_gather *tlb,
-					struct page *page, int page_size)
-{
-	return tlb_remove_page(tlb, page);
-}
-
-/*
- * Remove TLB entry for PTE mapped at virtual address ADDRESS.  This is called for any
- * PTE, not just those pointing to (normal) physical memory.
- */
-static inline void
-__tlb_remove_tlb_entry (struct mmu_gather *tlb, pte_t *ptep, unsigned long address)
-{
-	if (tlb->start_addr == ~0UL)
-		tlb->start_addr = address;
-	tlb->end_addr = address + PAGE_SIZE;
-}
-
 #define tlb_migrate_finish(mm)	platform_tlb_migrate_finish(mm)
 
-#define tlb_start_vma(tlb, vma)			do { } while (0)
-#define tlb_end_vma(tlb, vma)			do { } while (0)
-
-#define tlb_remove_tlb_entry(tlb, ptep, addr)		\
-do {							\
-	tlb->need_flush = 1;				\
-	__tlb_remove_tlb_entry(tlb, ptep, addr);	\
-} while (0)
-
-#define tlb_remove_huge_tlb_entry(h, tlb, ptep, address)	\
-	tlb_remove_tlb_entry(tlb, ptep, address)
-
-static inline void tlb_change_page_size(struct mmu_gather *tlb,
-						     unsigned int page_size)
-{
-}
-
-#define pte_free_tlb(tlb, ptep, address)		\
-do {							\
-	tlb->need_flush = 1;				\
-	__pte_free_tlb(tlb, ptep, address);		\
-} while (0)
-
-#define pmd_free_tlb(tlb, ptep, address)		\
-do {							\
-	tlb->need_flush = 1;				\
-	__pmd_free_tlb(tlb, ptep, address);		\
-} while (0)
-
-#define pud_free_tlb(tlb, pudp, address)		\
-do {							\
-	tlb->need_flush = 1;				\
-	__pud_free_tlb(tlb, pudp, address);		\
-} while (0)
+#include <asm-generic/tlb.h>
 
 #endif /* _ASM_IA64_TLB_H */
--- a/arch/ia64/include/asm/tlbflush.h
+++ b/arch/ia64/include/asm/tlbflush.h
@@ -14,6 +14,31 @@
 #include <asm/mmu_context.h>
 #include <asm/page.h>
 
+struct ia64_tr_entry {
+	u64 ifa;
+	u64 itir;
+	u64 pte;
+	u64 rr;
+}; /*Record for tr entry!*/
+
+extern int ia64_itr_entry(u64 target_mask, u64 va, u64 pte, u64 log_size);
+extern void ia64_ptr_entry(u64 target_mask, int slot);
+extern struct ia64_tr_entry *ia64_idtrs[NR_CPUS];
+
+/*
+ region register macros
+*/
+#define RR_TO_VE(val)   (((val) >> 0) & 0x0000000000000001)
+#define RR_VE(val)     (((val) & 0x0000000000000001) << 0)
+#define RR_VE_MASK     0x0000000000000001L
+#define RR_VE_SHIFT    0
+#define RR_TO_PS(val)  (((val) >> 2) & 0x000000000000003f)
+#define RR_PS(val)     (((val) & 0x000000000000003f) << 2)
+#define RR_PS_MASK     0x00000000000000fcL
+#define RR_PS_SHIFT    2
+#define RR_RID_MASK    0x00000000ffffff00L
+#define RR_TO_RID(val)         ((val >> 8) & 0xffffff)
+
 /*
  * Now for some TLB flushing routines.  This is the kind of stuff that
  * can be very expensive, so try to avoid them whenever possible.
--- a/arch/ia64/mm/tlb.c
+++ b/arch/ia64/mm/tlb.c
@@ -297,8 +297,8 @@ local_flush_tlb_all (void)
 	ia64_srlz_i();			/* srlz.i implies srlz.d */
 }
 
-void
-flush_tlb_range (struct vm_area_struct *vma, unsigned long start,
+static void
+__flush_tlb_range (struct vm_area_struct *vma, unsigned long start,
 		 unsigned long end)
 {
 	struct mm_struct *mm = vma->vm_mm;
@@ -335,6 +335,25 @@ flush_tlb_range (struct vm_area_struct *
 	preempt_enable();
 	ia64_srlz_i();			/* srlz.i implies srlz.d */
 }
+
+void flush_tlb_range(struct vm_area_struct *vma,
+		unsigned long start, unsigned long end)
+{
+	if (unlikely(end - start >= 1024*1024*1024*1024UL
+			|| REGION_NUMBER(start) != REGION_NUMBER(end - 1))) {
+		/*
+		 * If we flush more than a tera-byte or across regions, we're
+		 * probably better off just flushing the entire TLB(s).  This
+		 * should be very rare and is not worth optimizing for.
+		 */
+		flush_tlb_all();
+	} else {
+		/* flush the address range from the tlb */
+		__flush_tlb_range(vma, start, end);
+		/* flush the virt. page-table area mapping the addr range */
+		__flush_tlb_range(vma, ia64_thash(start), ia64_thash(end));
+	}
+}
 EXPORT_SYMBOL(flush_tlb_range);
 
 void ia64_tlb_init(void)


