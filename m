Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E5C1C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 10:33:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D4A0620818
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 10:33:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="cj6OXZas"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D4A0620818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4CA868E0004; Tue, 19 Feb 2019 05:32:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4747B8E0005; Tue, 19 Feb 2019 05:32:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2A0908E0004; Tue, 19 Feb 2019 05:32:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id ACFA48E0005
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 05:32:57 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id p20so14587106plr.22
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 02:32:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:user-agent:date:from
         :to:cc:subject:references:mime-version;
        bh=HElqsrLUWHidxAav0Qh/Fk5QOUwwf+dWAhbfrSNcsFA=;
        b=penQTpDqzDUo2cMiZBdPRvS2tRlt2io6cUQ+dNNPTnyS1z134X54WR77jFWFfloL9s
         DOqe4xYjVBBZJWHcuoKmDrbIXFxuiPuqJt2zDwSlQ2LSUhk4iDjfx/zzx3dQ3U45LcWu
         Iy+AtAXy9qLAjfc7msnlpd8PXaAiVtSEIJb/0+JBttu2/8BgCdpT/UGGkab/YktZswxs
         dOgZY4e0Ia6TuvVWHUikrIbihvPdvnLol7KyYC4nphbuQIVForaKFLc0Qa61cen6SN5t
         X58yenKZTmmy2fu19wvN1reVkPo08NRpxknNuQjNW8VK23XmaHLNYRRTskX2TmMNMp1y
         sy/A==
X-Gm-Message-State: AHQUAuYiJ/ZpU/z4iRl7tf67UqxXjAgV1aWnxOF78J8306vU+z8YNb7a
	df4qVfsUBx295D/ZPXCcNYQMO9Vxl/udCNpr5tYpnVcHz8ZqcgS5rdks25+M8QGiot4PzEsoybB
	xX4YibPFFydb3o9aSzNAfqqczxU16zmo+hEbTqL9jsrkPhZLlHE8BL1HBM7AfMAqd4A==
X-Received: by 2002:a17:902:988b:: with SMTP id s11mr30287636plp.162.1550572377273;
        Tue, 19 Feb 2019 02:32:57 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbVudgMzOR5uDuTxjrdlnVNUtG+N7YPCYujvF3gWpWFbr+RPLHW/P15e7FmLAuznB7UL/ws
X-Received: by 2002:a17:902:988b:: with SMTP id s11mr30287569plp.162.1550572376466;
        Tue, 19 Feb 2019 02:32:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550572376; cv=none;
        d=google.com; s=arc-20160816;
        b=vVm2xwqkT+2SMMzDV+VDFUJHRbDPSI4PhBdN++mRK+PB6iBkFsrYxV85BZT9QNWDn0
         dGf+iKD1IaGYlfZXXPAihg6sym3Ti6nD48Q0czV0FisHo1+ed0/WGhuvvLrHbZ0xf/u4
         Puzzo5W0AZpOWtd/gr/QjygsJwtqz5dgWu2XbzNuv4uM16rjDVgwBwF8xMRQuX9kkuzv
         qFukw+g8g8uJ5AOGxYTGDiGakZ70nb1gzcRZekNlrU799vdKB6FYqHH/D5TTmomgvtmP
         8YxehqD0NdSX9dpSrT7p3JF94fmgcD19Zary8eJ3T0iJMSB1dTe6q5lbS28U1N7s5Y2j
         2n/w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id:dkim-signature;
        bh=HElqsrLUWHidxAav0Qh/Fk5QOUwwf+dWAhbfrSNcsFA=;
        b=J2D7pLUz3tqMjnjpTXKuGTLz0kFdSKPTc/TDiPdeeozrYipehPcaOMLUp7WoBuX7ts
         Bmw4/QksY/kycFKQpWOnYlXQTfMDsU9bIBT9j6zt9+NtIlAWwjE3VJZ+B2nLmVwvr8Dl
         3axE9ZjxLsFCnAZ+i0On2RQRa7EDfeXDSbxo81bUdSeOWaBx8yQ/CYzvm3mUFf2sbn9H
         0aoDZyk4p0ZttFJP/1LEdpYpQNLYYRfdDRIzhAz/WCqcvz9UF48UlKs/jGGZnrX6GTV6
         j884VqNgpLbJbmUQBQjhJsZhyABi9uSY2q9gKfSFXFxMiUJrLbfDhatHVUKktDI6QsRr
         E5jQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=cj6OXZas;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s139si15749283pgs.45.2019.02.19.02.32.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 02:32:56 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=cj6OXZas;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Type:MIME-Version:References:
	Subject:Cc:To:From:Date:Message-Id:Sender:Reply-To:Content-Transfer-Encoding:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=HElqsrLUWHidxAav0Qh/Fk5QOUwwf+dWAhbfrSNcsFA=; b=cj6OXZasqey2dYPjv34knaMLkn
	cm00ZPSiCRjps/tY/8FwXplP2Mczqd7Du2x4RHiYcq3zHaVWDGARr+ReCv57+c8p8h524CERzQ1H3
	5xt3ENM0SGj0VBRQ0xHdBv6HmnHc+3bMk4AbjjaxxGLw9tD0ZtTCjI85eVvP7kwtum3xHroqMFJ4r
	1vlAgsou5oC0N+ydiu51NwIJ/12Ud0dCrHd2YmbslehrIipGPhGvwicffxkB47/T/yU5YxG7cM5O/
	GeAPR207701UFUorTolfnUloiB4maWwtnSiKdVAAToIL7xlGWxc+fX/wxxdR2Am2HvDly1JDLe6oR
	smgXSBUQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gw2hn-0006ZO-Rm; Tue, 19 Feb 2019 10:32:52 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 0)
	id 6179A285202CA; Tue, 19 Feb 2019 11:32:48 +0100 (CET)
Message-Id: <20190219103233.324160077@infradead.org>
User-Agent: quilt/0.65
Date: Tue, 19 Feb 2019 11:31:56 +0100
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
 riel@surriel.com
Subject: [PATCH v6 08/18] arm/tlb: Convert to generic mmu_gather
References: <20190219103148.192029670@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Generic mmu_gather provides everything that ARM needs:

 - range tracking
 - RCU table free
 - VM_EXEC tracking
 - VIPT cache flushing

The one notable curiosity is the 'funny' range tracking for classical
ARM in __pte_free_tlb().

Cc: Nick Piggin <npiggin@gmail.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Russell King <linux@armlinux.org.uk>
Acked-by: Will Deacon <will.deacon@arm.com>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/arm/include/asm/tlb.h |  254 ++-------------------------------------------
 1 file changed, 13 insertions(+), 241 deletions(-)

--- a/arch/arm/include/asm/tlb.h
+++ b/arch/arm/include/asm/tlb.h
@@ -33,270 +33,42 @@
 #include <asm/pgalloc.h>
 #include <asm/tlbflush.h>
 
-#define MMU_GATHER_BUNDLE	8
-
-#ifdef CONFIG_HAVE_RCU_TABLE_FREE
 static inline void __tlb_remove_table(void *_table)
 {
 	free_page_and_swap_cache((struct page *)_table);
 }
 
-struct mmu_table_batch {
-	struct rcu_head		rcu;
-	unsigned int		nr;
-	void			*tables[0];
-};
-
-#define MAX_TABLE_BATCH		\
-	((PAGE_SIZE - sizeof(struct mmu_table_batch)) / sizeof(void *))
-
-extern void tlb_table_flush(struct mmu_gather *tlb);
-extern void tlb_remove_table(struct mmu_gather *tlb, void *table);
-
-#define tlb_remove_entry(tlb, entry)	tlb_remove_table(tlb, entry)
-#else
-#define tlb_remove_entry(tlb, entry)	tlb_remove_page(tlb, entry)
-#endif /* CONFIG_HAVE_RCU_TABLE_FREE */
-
-/*
- * TLB handling.  This allows us to remove pages from the page
- * tables, and efficiently handle the TLB issues.
- */
-struct mmu_gather {
-	struct mm_struct	*mm;
-#ifdef CONFIG_HAVE_RCU_TABLE_FREE
-	struct mmu_table_batch	*batch;
-	unsigned int		need_flush;
-#endif
-	unsigned int		fullmm;
-	struct vm_area_struct	*vma;
-	unsigned long		start, end;
-	unsigned long		range_start;
-	unsigned long		range_end;
-	unsigned int		nr;
-	unsigned int		max;
-	struct page		**pages;
-	struct page		*local[MMU_GATHER_BUNDLE];
-};
-
-DECLARE_PER_CPU(struct mmu_gather, mmu_gathers);
-
-/*
- * This is unnecessarily complex.  There's three ways the TLB shootdown
- * code is used:
- *  1. Unmapping a range of vmas.  See zap_page_range(), unmap_region().
- *     tlb->fullmm = 0, and tlb_start_vma/tlb_end_vma will be called.
- *     tlb->vma will be non-NULL.
- *  2. Unmapping all vmas.  See exit_mmap().
- *     tlb->fullmm = 1, and tlb_start_vma/tlb_end_vma will be called.
- *     tlb->vma will be non-NULL.  Additionally, page tables will be freed.
- *  3. Unmapping argument pages.  See shift_arg_pages().
- *     tlb->fullmm = 0, but tlb_start_vma/tlb_end_vma will not be called.
- *     tlb->vma will be NULL.
- */
-static inline void tlb_flush(struct mmu_gather *tlb)
-{
-	if (tlb->fullmm || !tlb->vma)
-		flush_tlb_mm(tlb->mm);
-	else if (tlb->range_end > 0) {
-		flush_tlb_range(tlb->vma, tlb->range_start, tlb->range_end);
-		tlb->range_start = TASK_SIZE;
-		tlb->range_end = 0;
-	}
-}
-
-static inline void tlb_add_flush(struct mmu_gather *tlb, unsigned long addr)
-{
-	if (!tlb->fullmm) {
-		if (addr < tlb->range_start)
-			tlb->range_start = addr;
-		if (addr + PAGE_SIZE > tlb->range_end)
-			tlb->range_end = addr + PAGE_SIZE;
-	}
-}
-
-static inline void __tlb_alloc_page(struct mmu_gather *tlb)
-{
-	unsigned long addr = __get_free_pages(GFP_NOWAIT | __GFP_NOWARN, 0);
-
-	if (addr) {
-		tlb->pages = (void *)addr;
-		tlb->max = PAGE_SIZE / sizeof(struct page *);
-	}
-}
-
-static inline void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
-{
-	tlb_flush(tlb);
-#ifdef CONFIG_HAVE_RCU_TABLE_FREE
-	tlb_table_flush(tlb);
-#endif
-}
-
-static inline void tlb_flush_mmu_free(struct mmu_gather *tlb)
-{
-	free_pages_and_swap_cache(tlb->pages, tlb->nr);
-	tlb->nr = 0;
-	if (tlb->pages == tlb->local)
-		__tlb_alloc_page(tlb);
-}
-
-static inline void tlb_flush_mmu(struct mmu_gather *tlb)
-{
-	tlb_flush_mmu_tlbonly(tlb);
-	tlb_flush_mmu_free(tlb);
-}
-
-static inline void
-arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
-			unsigned long start, unsigned long end)
-{
-	tlb->mm = mm;
-	tlb->fullmm = !(start | (end+1));
-	tlb->start = start;
-	tlb->end = end;
-	tlb->vma = NULL;
-	tlb->max = ARRAY_SIZE(tlb->local);
-	tlb->pages = tlb->local;
-	tlb->nr = 0;
-	__tlb_alloc_page(tlb);
+#include <asm-generic/tlb.h>
 
-#ifdef CONFIG_HAVE_RCU_TABLE_FREE
-	tlb->batch = NULL;
+#ifndef CONFIG_HAVE_RCU_TABLE_FREE
+#define tlb_remove_table(tlb, entry) tlb_remove_page(tlb, entry)
 #endif
-}
-
-static inline void
-arch_tlb_finish_mmu(struct mmu_gather *tlb,
-			unsigned long start, unsigned long end, bool force)
-{
-	if (force) {
-		tlb->range_start = start;
-		tlb->range_end = end;
-	}
-
-	tlb_flush_mmu(tlb);
 
-	/* keep the page table cache within bounds */
-	check_pgt_cache();
-
-	if (tlb->pages != tlb->local)
-		free_pages((unsigned long)tlb->pages, 0);
-}
-
-/*
- * Memorize the range for the TLB flush.
- */
 static inline void
-tlb_remove_tlb_entry(struct mmu_gather *tlb, pte_t *ptep, unsigned long addr)
-{
-	tlb_add_flush(tlb, addr);
-}
-
-#define tlb_remove_huge_tlb_entry(h, tlb, ptep, address)	\
-	tlb_remove_tlb_entry(tlb, ptep, address)
-/*
- * In the case of tlb vma handling, we can optimise these away in the
- * case where we're doing a full MM flush.  When we're doing a munmap,
- * the vmas are adjusted to only cover the region to be torn down.
- */
-static inline void
-tlb_start_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
-{
-	if (!tlb->fullmm) {
-		flush_cache_range(vma, vma->vm_start, vma->vm_end);
-		tlb->vma = vma;
-		tlb->range_start = TASK_SIZE;
-		tlb->range_end = 0;
-	}
-}
-
-static inline void
-tlb_end_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
-{
-	if (!tlb->fullmm)
-		tlb_flush(tlb);
-}
-
-static inline bool __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
-{
-	tlb->pages[tlb->nr++] = page;
-	VM_WARN_ON(tlb->nr > tlb->max);
-	if (tlb->nr == tlb->max)
-		return true;
-	return false;
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
-static inline void __pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte,
-	unsigned long addr)
+__pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte, unsigned long addr)
 {
 	pgtable_page_dtor(pte);
 
-#ifdef CONFIG_ARM_LPAE
-	tlb_add_flush(tlb, addr);
-#else
+#ifndef CONFIG_ARM_LPAE
 	/*
 	 * With the classic ARM MMU, a pte page has two corresponding pmd
 	 * entries, each covering 1MB.
 	 */
-	addr &= PMD_MASK;
-	tlb_add_flush(tlb, addr + SZ_1M - PAGE_SIZE);
-	tlb_add_flush(tlb, addr + SZ_1M);
+	addr = (addr & PMD_MASK) + SZ_1M;
+	__tlb_adjust_range(tlb, addr - PAGE_SIZE, 2 * PAGE_SIZE);
 #endif
 
-	tlb_remove_entry(tlb, pte);
-}
-
-static inline void __pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmdp,
-				  unsigned long addr)
-{
-#ifdef CONFIG_ARM_LPAE
-	tlb_add_flush(tlb, addr);
-	tlb_remove_entry(tlb, virt_to_page(pmdp));
-#endif
+	tlb_remove_table(tlb, pte);
 }
 
 static inline void
-tlb_remove_pmd_tlb_entry(struct mmu_gather *tlb, pmd_t *pmdp, unsigned long addr)
+__pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmdp, unsigned long addr)
 {
-	tlb_add_flush(tlb, addr);
-}
-
-#define pte_free_tlb(tlb, ptep, addr)	__pte_free_tlb(tlb, ptep, addr)
-#define pmd_free_tlb(tlb, pmdp, addr)	__pmd_free_tlb(tlb, pmdp, addr)
-#define pud_free_tlb(tlb, pudp, addr)	pud_free((tlb)->mm, pudp)
-
-#define tlb_migrate_finish(mm)		do { } while (0)
-
-static inline void tlb_change_page_size(struct mmu_gather *tlb,
-						     unsigned int page_size)
-{
-}
-
-static inline void tlb_flush_remove_tables(struct mm_struct *mm)
-{
-}
+#ifdef CONFIG_ARM_LPAE
+	struct page *page = virt_to_page(pmdp);
 
-static inline void tlb_flush_remove_tables_local(void *arg)
-{
+	tlb_remove_table(tlb, page);
+#endif
 }
 
 #endif /* CONFIG_MMU */


