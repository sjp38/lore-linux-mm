Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A5BE2C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 10:33:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 576C820818
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 10:33:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="GNxZaIPf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 576C820818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 88EED8E0007; Tue, 19 Feb 2019 05:32:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8158C8E0005; Tue, 19 Feb 2019 05:32:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 642FB8E0007; Tue, 19 Feb 2019 05:32:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1DE7D8E0005
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 05:32:59 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id 38so12228197pld.6
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 02:32:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:user-agent:date:from
         :to:cc:subject:references:mime-version;
        bh=RpJiJa8CBPMPOdWg2ETJIDRPRiReNjHxoWWV5r1499c=;
        b=YzOdcVMMXdFN8uuz26vY/WbQYLGM3tABxWwZJrVfTADaDUWM+xde3IG8ttuE3LYyPm
         SHGPHrCSmiNWIDk2kzX2YZUd+b0f42Vd4jK2rGw2wTNbcYmlecvLo/S3IF7eBCYdu4U2
         oeIAScbf+05dC3hC+63zHaCrGj+VNBoqqAjNf25C5l3P+ehHIbpnjC44bDx9nw+TqleX
         +W7uO5iQFLuSZ5hRul51heZKnRc1ONnYQbOcViW/r/K+HyDSr8hIBRsNMUiPrFbMILk9
         dPpLAkA+fCa2t1dJj1mIQ0GhrdE6jTeR9U3TJDRipSYn6oPa3LUjpp3PgLMHMYq7vtr+
         4KCg==
X-Gm-Message-State: AHQUAuZbzEIF+qcrH/FseKDul/actKt/bwySz9WtEG20+J+Z5J6nzMHc
	mWaxNhmxcqLD787Ff2YPUB6Z68BUIU62EYrTNu9IxcOAFTSQgVCOq6ewBj6mhQ7iD4opIzeEvd0
	2mZz/8hbfsp6RJ2e7SG5TYGCMZqORBdOFLRBGDtTKkE9TkBoxMAi444YY/Zq5jD/bXA==
X-Received: by 2002:a63:2e06:: with SMTP id u6mr23137293pgu.71.1550572378729;
        Tue, 19 Feb 2019 02:32:58 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYiokJ9UPqynZHmAtefNRxjbcOhYo0i+wSD2jpSw4iTDEyddwzTolVmNHYj73BFfiVq7ffH
X-Received: by 2002:a63:2e06:: with SMTP id u6mr23137234pgu.71.1550572377833;
        Tue, 19 Feb 2019 02:32:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550572377; cv=none;
        d=google.com; s=arc-20160816;
        b=IzZhKUyRDWhbr3AxoufVa/F8PGsp2qhzGocF5wDHYl6xwvzX/AAR3LfiOSCDbFO5GB
         z+IOj6/kEDfFEZaHam8Cgwoqr3Qto9AnK4xoubvJTHPcPAANFhE89rlFUaozAyCNeBVm
         RhINk5DAw2rtPlPAH3EtAm2Zrj0lBUzMh87/YXxvCriJ3AjrbOsmu8R4r5f1vWXrk4j8
         oqCzdi8kovOrHs3fxjBMP9MAzWARq3EXT8K2w1krZVXbQlPdgqiRyVHO1s/9UdLLly5c
         Lt1NzS2l0XAPKaxVLdUPSRalxmKT+a8HVTdXeRxz6xdfdN6HMOQrcZwPkBx6eUzzOEK5
         5dDA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id:dkim-signature;
        bh=RpJiJa8CBPMPOdWg2ETJIDRPRiReNjHxoWWV5r1499c=;
        b=aVpSANq87snCcSkAGj9gZYfywwjsb2fER5s9wYznU5jQ4BME/kdcRE3Pmz5eeDSAOi
         u0KmyJH9+vTMwobrILkpsC9kFCD+HxgEyAXst95kE32tUmuuLM+w3+XMIS8y9ZjKhDUx
         Kp+tI83uSJoJ2gqRDIJabvV2TiTZ1gUPAeYaxCD3RUP8bZkAj8aBV0F6WQ/dZTXvLA2b
         QA+URcoG8YGhnZZnsJP0kcceWuOY2qdxxo14rVT554c338RJ7dUaP9MLfO7Hq92t7BZB
         RuuGF6VF4UEeVU4v/ItIwlDFB2lf2hSnYNHOBAR5u6CzyeN8jcaFDB/T76lj+Up3K/dF
         ZR5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=GNxZaIPf;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id p22si15295372pgl.340.2019.02.19.02.32.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 02:32:57 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=GNxZaIPf;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Type:MIME-Version:References:
	Subject:Cc:To:From:Date:Message-Id:Sender:Reply-To:Content-Transfer-Encoding:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=RpJiJa8CBPMPOdWg2ETJIDRPRiReNjHxoWWV5r1499c=; b=GNxZaIPfqlPSblbBh4LaOu1wrJ
	E0XbIapBnlyJHbEfT4sl3khjh5+wdQmvd2Cf0qOEzzyMkOHT438I5O7UdajNPoXGFSkpvQ+dfreTh
	qlBTJ/L41iOIY6CVf5RUSpqPfmh7s6y90ppgJpvjDFW9bnJSc3kn6te/0T+DOEKTmZq7+WSJ51xf2
	DHUVSrvEwx5Fc6BeFzy9UG315tLX5zXkF/9X/bf8my9WlHgBxhYosAukxNmWMnb/smdwZTRVsK2yw
	eR1se3eJ88d4xCBCGtw0cMj9Mrmux+90TZOkzNCokvJz2VMhYbe85CUFkn7yf93g0BA/xotovRvN1
	DM/c5YPw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gw2hn-0006ZK-01; Tue, 19 Feb 2019 10:32:51 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 0)
	id 4A4FC285202C4; Tue, 19 Feb 2019 11:32:48 +0100 (CET)
Message-Id: <20190219103232.970991705@infradead.org>
User-Agent: quilt/0.65
Date: Tue, 19 Feb 2019 11:31:50 +0100
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
Subject: [PATCH v6 02/18] asm-generic/tlb: Provide HAVE_MMU_GATHER_PAGE_SIZE
References: <20190219103148.192029670@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Move the mmu_gather::page_size things into the generic code instead of
powerpc specific bits.

Cc: Nick Piggin <npiggin@gmail.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Acked-by: Will Deacon <will.deacon@arm.com>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/Kconfig                   |    3 +++
 arch/arm/include/asm/tlb.h     |    3 +--
 arch/ia64/include/asm/tlb.h    |    3 +--
 arch/powerpc/Kconfig           |    1 +
 arch/powerpc/include/asm/tlb.h |   17 -----------------
 arch/s390/include/asm/tlb.h    |    4 +---
 arch/sh/include/asm/tlb.h      |    4 +---
 arch/um/include/asm/tlb.h      |    4 +---
 include/asm-generic/tlb.h      |   32 +++++++++++++++++++-------------
 mm/huge_memory.c               |    4 ++--
 mm/hugetlb.c                   |    2 +-
 mm/madvise.c                   |    2 +-
 mm/memory.c                    |    4 ++--
 mm/mmu_gather.c                |    5 +++++
 14 files changed, 39 insertions(+), 49 deletions(-)

--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -368,6 +368,9 @@ config HAVE_RCU_TABLE_FREE
 config HAVE_RCU_TABLE_INVALIDATE
 	bool
 
+config HAVE_MMU_GATHER_PAGE_SIZE
+	bool
+
 config ARCH_HAVE_NMI_SAFE_CMPXCHG
 	bool
 
--- a/arch/arm/include/asm/tlb.h
+++ b/arch/arm/include/asm/tlb.h
@@ -286,8 +286,7 @@ tlb_remove_pmd_tlb_entry(struct mmu_gath
 
 #define tlb_migrate_finish(mm)		do { } while (0)
 
-#define tlb_remove_check_page_size_change tlb_remove_check_page_size_change
-static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
+static inline void tlb_change_page_size(struct mmu_gather *tlb,
 						     unsigned int page_size)
 {
 }
--- a/arch/ia64/include/asm/tlb.h
+++ b/arch/ia64/include/asm/tlb.h
@@ -282,8 +282,7 @@ do {							\
 #define tlb_remove_huge_tlb_entry(h, tlb, ptep, address)	\
 	tlb_remove_tlb_entry(tlb, ptep, address)
 
-#define tlb_remove_check_page_size_change tlb_remove_check_page_size_change
-static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
+static inline void tlb_change_page_size(struct mmu_gather *tlb,
 						     unsigned int page_size)
 {
 }
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -216,6 +216,7 @@ config PPC
 	select HAVE_PERF_REGS
 	select HAVE_PERF_USER_STACK_DUMP
 	select HAVE_RCU_TABLE_FREE		if SMP
+	select HAVE_MMU_GATHER_PAGE_SIZE
 	select HAVE_REGS_AND_STACK_ACCESS_API
 	select HAVE_RELIABLE_STACKTRACE		if PPC64 && CPU_LITTLE_ENDIAN
 	select HAVE_SYSCALL_TRACEPOINTS
--- a/arch/powerpc/include/asm/tlb.h
+++ b/arch/powerpc/include/asm/tlb.h
@@ -27,7 +27,6 @@
 #define tlb_start_vma(tlb, vma)	do { } while (0)
 #define tlb_end_vma(tlb, vma)	do { } while (0)
 #define __tlb_remove_tlb_entry	__tlb_remove_tlb_entry
-#define tlb_remove_check_page_size_change tlb_remove_check_page_size_change
 
 extern void tlb_flush(struct mmu_gather *tlb);
 
@@ -46,22 +45,6 @@ static inline void __tlb_remove_tlb_entr
 #endif
 }
 
-static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
-						     unsigned int page_size)
-{
-	if (!tlb->page_size)
-		tlb->page_size = page_size;
-	else if (tlb->page_size != page_size) {
-		if (!tlb->fullmm)
-			tlb_flush_mmu(tlb);
-		/*
-		 * update the page size after flush for the new
-		 * mmu_gather.
-		 */
-		tlb->page_size = page_size;
-	}
-}
-
 #ifdef CONFIG_SMP
 static inline int mm_is_core_local(struct mm_struct *mm)
 {
--- a/arch/s390/include/asm/tlb.h
+++ b/arch/s390/include/asm/tlb.h
@@ -180,9 +180,7 @@ static inline void pud_free_tlb(struct m
 #define tlb_remove_huge_tlb_entry(h, tlb, ptep, address)	\
 	tlb_remove_tlb_entry(tlb, ptep, address)
 
-#define tlb_remove_check_page_size_change tlb_remove_check_page_size_change
-static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
-						     unsigned int page_size)
+static inline void tlb_change_page_size(struct mmu_gather *tlb, unsigned int page_size)
 {
 }
 
--- a/arch/sh/include/asm/tlb.h
+++ b/arch/sh/include/asm/tlb.h
@@ -127,9 +127,7 @@ static inline void tlb_remove_page_size(
 	return tlb_remove_page(tlb, page);
 }
 
-#define tlb_remove_check_page_size_change tlb_remove_check_page_size_change
-static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
-						     unsigned int page_size)
+static inline void tlb_change_page_size(struct mmu_gather *tlb, unsigned int page_size)
 {
 }
 
--- a/arch/um/include/asm/tlb.h
+++ b/arch/um/include/asm/tlb.h
@@ -146,9 +146,7 @@ static inline void tlb_remove_page_size(
 #define tlb_remove_huge_tlb_entry(h, tlb, ptep, address)	\
 	tlb_remove_tlb_entry(tlb, ptep, address)
 
-#define tlb_remove_check_page_size_change tlb_remove_check_page_size_change
-static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
-						     unsigned int page_size)
+static inline void tlb_change_page_size(struct mmu_gather *tlb, unsigned int page_size)
 {
 }
 
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -61,7 +61,7 @@
  *    tlb_remove_page() and tlb_remove_page_size() imply the call to
  *    tlb_flush_mmu() when required and has no return value.
  *
- *  - tlb_remove_check_page_size_change()
+ *  - tlb_change_page_size()
  *
  *    call before __tlb_remove_page*() to set the current page-size; implies a
  *    possible tlb_flush_mmu() call.
@@ -114,6 +114,11 @@
  *
  * Additionally there are a few opt-in features:
  *
+ *  HAVE_MMU_GATHER_PAGE_SIZE
+ *
+ *  This ensures we call tlb_flush() every time tlb_change_page_size() actually
+ *  changes the size and provides mmu_gather::page_size to tlb_flush().
+ *
  *  HAVE_RCU_TABLE_FREE
  *
  *  This provides tlb_remove_table(), to be used instead of tlb_remove_page()
@@ -239,11 +244,15 @@ struct mmu_gather {
 	unsigned int		cleared_puds : 1;
 	unsigned int		cleared_p4ds : 1;
 
+	unsigned int		batch_count;
+
 	struct mmu_gather_batch *active;
 	struct mmu_gather_batch	local;
 	struct page		*__pages[MMU_GATHER_BUNDLE];
-	unsigned int		batch_count;
-	int page_size;
+
+#ifdef CONFIG_HAVE_MMU_GATHER_PAGE_SIZE
+	unsigned int page_size;
+#endif
 };
 
 void arch_tlb_gather_mmu(struct mmu_gather *tlb,
@@ -309,21 +318,18 @@ static inline void tlb_remove_page(struc
 	return tlb_remove_page_size(tlb, page, PAGE_SIZE);
 }
 
-#ifndef tlb_remove_check_page_size_change
-#define tlb_remove_check_page_size_change tlb_remove_check_page_size_change
-static inline void tlb_remove_check_page_size_change(struct mmu_gather *tlb,
+static inline void tlb_change_page_size(struct mmu_gather *tlb,
 						     unsigned int page_size)
 {
-	/*
-	 * We don't care about page size change, just update
-	 * mmu_gather page size here so that debug checks
-	 * doesn't throw false warning.
-	 */
-#ifdef CONFIG_DEBUG_VM
+#ifdef CONFIG_HAVE_MMU_GATHER_PAGE_SIZE
+	if (tlb->page_size && tlb->page_size != page_size) {
+		if (!tlb->fullmm)
+			tlb_flush_mmu(tlb);
+	}
+
 	tlb->page_size = page_size;
 #endif
 }
-#endif
 
 static inline unsigned long tlb_get_unmap_shift(struct mmu_gather *tlb)
 {
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1617,7 +1617,7 @@ bool madvise_free_huge_pmd(struct mmu_ga
 	struct mm_struct *mm = tlb->mm;
 	bool ret = false;
 
-	tlb_remove_check_page_size_change(tlb, HPAGE_PMD_SIZE);
+	tlb_change_page_size(tlb, HPAGE_PMD_SIZE);
 
 	ptl = pmd_trans_huge_lock(pmd, vma);
 	if (!ptl)
@@ -1693,7 +1693,7 @@ int zap_huge_pmd(struct mmu_gather *tlb,
 	pmd_t orig_pmd;
 	spinlock_t *ptl;
 
-	tlb_remove_check_page_size_change(tlb, HPAGE_PMD_SIZE);
+	tlb_change_page_size(tlb, HPAGE_PMD_SIZE);
 
 	ptl = __pmd_trans_huge_lock(pmd, vma);
 	if (!ptl)
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3337,7 +3337,7 @@ void __unmap_hugepage_range(struct mmu_g
 	 * This is a hugetlb vma, all the pte entries should point
 	 * to huge page.
 	 */
-	tlb_remove_check_page_size_change(tlb, sz);
+	tlb_change_page_size(tlb, sz);
 	tlb_start_vma(tlb, vma);
 
 	/*
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -328,7 +328,7 @@ static int madvise_free_pte_range(pmd_t
 	if (pmd_trans_unstable(pmd))
 		return 0;
 
-	tlb_remove_check_page_size_change(tlb, PAGE_SIZE);
+	tlb_change_page_size(tlb, PAGE_SIZE);
 	orig_pte = pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
 	flush_tlb_batched_pending(mm);
 	arch_enter_lazy_mmu_mode();
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -355,7 +355,7 @@ void free_pgd_range(struct mmu_gather *t
 	 * We add page table cache pages with PAGE_SIZE,
 	 * (see pte_free_tlb()), flush the tlb if we need
 	 */
-	tlb_remove_check_page_size_change(tlb, PAGE_SIZE);
+	tlb_change_page_size(tlb, PAGE_SIZE);
 	pgd = pgd_offset(tlb->mm, addr);
 	do {
 		next = pgd_addr_end(addr, end);
@@ -1046,7 +1046,7 @@ static unsigned long zap_pte_range(struc
 	pte_t *pte;
 	swp_entry_t entry;
 
-	tlb_remove_check_page_size_change(tlb, PAGE_SIZE);
+	tlb_change_page_size(tlb, PAGE_SIZE);
 again:
 	init_rss_vec(rss);
 	start_pte = pte_offset_map_lock(mm, pmd, addr, &ptl);
--- a/mm/mmu_gather.c
+++ b/mm/mmu_gather.c
@@ -58,7 +58,9 @@ void arch_tlb_gather_mmu(struct mmu_gath
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	tlb->batch = NULL;
 #endif
+#ifdef CONFIG_HAVE_MMU_GATHER_PAGE_SIZE
 	tlb->page_size = 0;
+#endif
 
 	__tlb_reset_range(tlb);
 }
@@ -121,7 +123,10 @@ bool __tlb_remove_page_size(struct mmu_g
 	struct mmu_gather_batch *batch;
 
 	VM_BUG_ON(!tlb->end);
+
+#ifdef CONFIG_HAVE_MMU_GATHER_PAGE_SIZE
 	VM_WARN_ON(tlb->page_size != page_size);
+#endif
 
 	batch = tlb->active;
 	/*


