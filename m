Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3AFB0C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 10:33:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DD36420818
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 10:33:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="vJiFspkn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DD36420818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E0D138E000E; Tue, 19 Feb 2019 05:33:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D987C8E0005; Tue, 19 Feb 2019 05:33:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AAEF18E000F; Tue, 19 Feb 2019 05:33:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 789418E000E
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 05:33:05 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id r136so3616864ith.3
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 02:33:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:user-agent:date:from
         :to:cc:subject:references:mime-version;
        bh=5h0BErUbkhYOuxC4AEQQHwepBLlBB1bYvtBry5aU02U=;
        b=JuK2AM/CHc15B9QUWQlCFHqDIwJgr8slJY8a5ipcxv8dA4yzIJbmpV3dCABxZrlayI
         k7DutCh7cprtNcDJNyzkvkS94Lnv1ZDjcNx7D26v7iDuAFbKlUBEmR2RN20sqlVR7lP+
         9RcD8g8AIOlGaNSwsVtP/YHohDggtbP9F6e6jwgnD3vR5yHniWz+hBx7DtZ6Hj6321mf
         k77ehhZvgfSVJ0UeJdtUQ7xQLHr60bPxEWLAfnY/IqCtiVkdZeQg7dOSfZi7Iq/nchgO
         /lWJCxc7zp4pp6GuL+wdDMBEQRZJpljJVsf5wDE9OjVtXvCb2lOR231nyp6FJq5O0KLl
         jZXQ==
X-Gm-Message-State: AHQUAuaSTZtisYceuIc5dDYaGQ1qfD6JorEcw6nSbn/i2CheAx5YeT2u
	HmIttMLdKcM0vtMrXwmRVEs95pqxBLPHyCPeJOJJwVkirPYR5bYCPmgN3jI8U+zPWWFevlb28yx
	gPVF2Yz3XIvFS8rfC4rrCtxN4xv76sz3JTQK6qUJLhGj9If4WWaFIZO3t1oa+uB96Ew==
X-Received: by 2002:a6b:b241:: with SMTP id b62mr15641308iof.261.1550572385226;
        Tue, 19 Feb 2019 02:33:05 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaYbvhwCRafIrEhRZBDPFNYLUzZMZLsgcyAkEgQOUW52Mxyn4ifDjsnwrpfYzoXox5YRA+Z
X-Received: by 2002:a6b:b241:: with SMTP id b62mr15641283iof.261.1550572384448;
        Tue, 19 Feb 2019 02:33:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550572384; cv=none;
        d=google.com; s=arc-20160816;
        b=eltkkM/oUmCqWndS4qk/7R/wd4HBpMnyNhTRgj1TKNyFZRLu2BwkcOn/VlX9IYAbxC
         fGgEHTcq1pkKWHQxEbz13ttnnFz+a1nnHwe5WE8HCElmRA8EiPT+NZODeuk1JMydwWBW
         UTWmoB78aIkjxHiLqmvOzRZ/w0uVV6eEaIQE+QiaIXYNZLcNCVs0HwukN9XqX/D//jXm
         XOI0a++s6YwTClFN5qiDh2R2LZbCUJVmWwYQputjjMvNL9JfmHKwK3UbvHm+OI5rT7tA
         9VXIpx8dndGFeSvEW0vKoUuFmiekfPEwgW+5oTRDbqNI47ewYwjdAuo9adqxpP9tE5OD
         hTUg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id:dkim-signature;
        bh=5h0BErUbkhYOuxC4AEQQHwepBLlBB1bYvtBry5aU02U=;
        b=mT3Mw8saoopWUbOuKFNSHX38wjUBcpLo4gViHdQmYjayDNR+EwOs0iMqX6lnpVuS/P
         b0MhAt+FYCATYfMBAfa3EKTbl6eEg+WzPn+5Oob1YMzTnN3XZu/t85bCyOnArG2Ok355
         MURNgM8jz2jT8IEydhSP3BML5X0KlK+cc3mVkcdOIDedVq7cLxiLdCnpKez6DWzaG+/A
         yAHos6vgVDKhVRKKFijWKwLiu9biFVFyBjJXNAokzNwr7LZypWB1elP6BDlEo4jZnZkK
         pd7bg/fr5Ji0yQD41PSkArFovHmCKVKNHxv0C6N9O+5VAhGKbBNcv2NK0Fg2fBsfmU3k
         Rs5g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=vJiFspkn;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id s64si4492072jaa.98.2019.02.19.02.33.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 02:33:04 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=vJiFspkn;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Type:MIME-Version:References:
	Subject:Cc:To:From:Date:Message-Id:Sender:Reply-To:Content-Transfer-Encoding:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=5h0BErUbkhYOuxC4AEQQHwepBLlBB1bYvtBry5aU02U=; b=vJiFspknW4JLU6ylcMMuRaKWu6
	4nVr31kp2Dt8zQtO1uiPPmNQK4Uh7vKz2cAYlcJEsHcTW2qHE6BGtZzRZdih1omaBVBLyEG+Qb0EE
	QVEV4+HvNwKzlwrOFB2MiKsBk5/3KkQ6Jkbp3XWEIFKYIM+MqYx9hMadXLYVGUQseBuFy0L9wguwG
	x8qJaIt73/YSdgE/7TnY4OwdQ4ab81mLDZGU0TIr43Sl1E6DiY5b6WXcxzeKRYKt4cluvvPL2WjY0
	gLNWgZcfiAodDZ65P16em0b5W9x5hM7yBVv2QZNTXAdaSOF4Q21f6+0zoblXq4/Oxe1tCXMDITbQA
	mlx7mhYg==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gw2ho-0000dn-Dh; Tue, 19 Feb 2019 10:32:52 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 0)
	id 75EC0285205A1; Tue, 19 Feb 2019 11:32:48 +0100 (CET)
Message-Id: <20190219103233.693323478@infradead.org>
User-Agent: quilt/0.65
Date: Tue, 19 Feb 2019 11:32:02 +0100
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
 Linus Torvalds <torvalds@linux-foundation.org>,
 Martin Schwidefsky <schwidefsky@de.ibm.com>
Subject: [PATCH v6 14/18] s390/tlb: convert to generic mmu_gather
References: <20190219103148.192029670@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


Cc: heiko.carstens@de.ibm.com
Cc: npiggin@gmail.com
Cc: akpm@linux-foundation.org
Cc: aneesh.kumar@linux.vnet.ibm.com
Cc: will.deacon@arm.com
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux@armlinux.org.uk
Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Link: http://lkml.kernel.org/r/20180918125151.31744-3-schwidefsky@de.ibm.com
---
 arch/s390/Kconfig           |    2 
 arch/s390/include/asm/tlb.h |  128 +++++++++++++-------------------------------
 arch/s390/mm/pgalloc.c      |   63 ---------------------
 3 files changed, 42 insertions(+), 151 deletions(-)

--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -163,11 +163,13 @@ config S390
 	select HAVE_PERF_USER_STACK_DUMP
 	select HAVE_MEMBLOCK_NODE_MAP
 	select HAVE_MEMBLOCK_PHYS_MAP
+	select HAVE_MMU_GATHER_NO_GATHER
 	select HAVE_MOD_ARCH_SPECIFIC
 	select HAVE_NOP_MCOUNT
 	select HAVE_OPROFILE
 	select HAVE_PCI
 	select HAVE_PERF_EVENTS
+	select HAVE_RCU_TABLE_FREE
 	select HAVE_REGS_AND_STACK_ACCESS_API
 	select HAVE_RSEQ
 	select HAVE_SYSCALL_TRACEPOINTS
--- a/arch/s390/include/asm/tlb.h
+++ b/arch/s390/include/asm/tlb.h
@@ -22,98 +22,39 @@
  * Pages used for the page tables is a different story. FIXME: more
  */
 
-#include <linux/mm.h>
-#include <linux/pagemap.h>
-#include <linux/swap.h>
-#include <asm/processor.h>
-#include <asm/pgalloc.h>
-#include <asm/tlbflush.h>
-
-struct mmu_gather {
-	struct mm_struct *mm;
-	struct mmu_table_batch *batch;
-	unsigned int fullmm;
-	unsigned long start, end;
-};
-
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
-static inline void
-arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
-			unsigned long start, unsigned long end)
-{
-	tlb->mm = mm;
-	tlb->start = start;
-	tlb->end = end;
-	tlb->fullmm = !(start | (end+1));
-	tlb->batch = NULL;
-}
-
-static inline void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
-{
-	__tlb_flush_mm_lazy(tlb->mm);
-}
-
-static inline void tlb_flush_mmu_free(struct mmu_gather *tlb)
-{
-	tlb_table_flush(tlb);
-}
-
+void __tlb_remove_table(void *_table);
+static inline void tlb_flush(struct mmu_gather *tlb);
+static inline bool __tlb_remove_page_size(struct mmu_gather *tlb,
+					  struct page *page, int page_size);
 
-static inline void tlb_flush_mmu(struct mmu_gather *tlb)
-{
-	tlb_flush_mmu_tlbonly(tlb);
-	tlb_flush_mmu_free(tlb);
-}
+#define tlb_start_vma(tlb, vma)			do { } while (0)
+#define tlb_end_vma(tlb, vma)			do { } while (0)
 
-static inline void
-arch_tlb_finish_mmu(struct mmu_gather *tlb,
-		unsigned long start, unsigned long end, bool force)
-{
-	if (force) {
-		tlb->start = start;
-		tlb->end = end;
-	}
+#define tlb_flush tlb_flush
+#define pte_free_tlb pte_free_tlb
+#define pmd_free_tlb pmd_free_tlb
+#define p4d_free_tlb p4d_free_tlb
+#define pud_free_tlb pud_free_tlb
 
-	tlb_flush_mmu(tlb);
-}
+#include <asm/pgalloc.h>
+#include <asm/tlbflush.h>
+#include <asm-generic/tlb.h>
 
 /*
  * Release the page cache reference for a pte removed by
  * tlb_ptep_clear_flush. In both flush modes the tlb for a page cache page
  * has already been freed, so just do free_page_and_swap_cache.
  */
-static inline bool __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
-{
-	free_page_and_swap_cache(page);
-	return false; /* avoid calling tlb_flush_mmu */
-}
-
-static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
-{
-	free_page_and_swap_cache(page);
-}
-
 static inline bool __tlb_remove_page_size(struct mmu_gather *tlb,
 					  struct page *page, int page_size)
 {
-	return __tlb_remove_page(tlb, page);
+	free_page_and_swap_cache(page);
+	return false;
 }
 
-static inline void tlb_remove_page_size(struct mmu_gather *tlb,
-					struct page *page, int page_size)
+static inline void tlb_flush(struct mmu_gather *tlb)
 {
-	return tlb_remove_page(tlb, page);
+	__tlb_flush_mm_lazy(tlb->mm);
 }
 
 /*
@@ -121,8 +62,17 @@ static inline void tlb_remove_page_size(
  * page table from the tlb.
  */
 static inline void pte_free_tlb(struct mmu_gather *tlb, pgtable_t pte,
-				unsigned long address)
+                                unsigned long address)
 {
+	__tlb_adjust_range(tlb, address, PAGE_SIZE);
+	tlb->mm->context.flush_mm = 1;
+	tlb->freed_tables = 1;
+	tlb->cleared_ptes = 1;
+	/*
+	 * page_table_free_rcu takes care of the allocation bit masks
+	 * of the 2K table fragments in the 4K page table page,
+	 * then calls tlb_remove_table.
+	 */
 	page_table_free_rcu(tlb, (unsigned long *) pte, address);
 }
 
@@ -139,6 +89,10 @@ static inline void pmd_free_tlb(struct m
 	if (mm_pmd_folded(tlb->mm))
 		return;
 	pgtable_pmd_page_dtor(virt_to_page(pmd));
+	__tlb_adjust_range(tlb, address, PAGE_SIZE);
+	tlb->mm->context.flush_mm = 1;
+	tlb->freed_tables = 1;
+	tlb->cleared_puds = 1;
 	tlb_remove_table(tlb, pmd);
 }
 
@@ -154,6 +108,10 @@ static inline void p4d_free_tlb(struct m
 {
 	if (mm_p4d_folded(tlb->mm))
 		return;
+	__tlb_adjust_range(tlb, address, PAGE_SIZE);
+	tlb->mm->context.flush_mm = 1;
+	tlb->freed_tables = 1;
+	tlb->cleared_p4ds = 1;
 	tlb_remove_table(tlb, p4d);
 }
 
@@ -169,19 +127,11 @@ static inline void pud_free_tlb(struct m
 {
 	if (mm_pud_folded(tlb->mm))
 		return;
+	tlb->mm->context.flush_mm = 1;
+	tlb->freed_tables = 1;
+	tlb->cleared_puds = 1;
 	tlb_remove_table(tlb, pud);
 }
 
-#define tlb_start_vma(tlb, vma)			do { } while (0)
-#define tlb_end_vma(tlb, vma)			do { } while (0)
-#define tlb_remove_tlb_entry(tlb, ptep, addr)	do { } while (0)
-#define tlb_remove_pmd_tlb_entry(tlb, pmdp, addr)	do { } while (0)
-#define tlb_migrate_finish(mm)			do { } while (0)
-#define tlb_remove_huge_tlb_entry(h, tlb, ptep, address)	\
-	tlb_remove_tlb_entry(tlb, ptep, address)
-
-static inline void tlb_change_page_size(struct mmu_gather *tlb, unsigned int page_size)
-{
-}
 
 #endif /* _S390_TLB_H */
--- a/arch/s390/mm/pgalloc.c
+++ b/arch/s390/mm/pgalloc.c
@@ -290,7 +290,7 @@ void page_table_free_rcu(struct mmu_gath
 	tlb_remove_table(tlb, table);
 }
 
-static void __tlb_remove_table(void *_table)
+void __tlb_remove_table(void *_table)
 {
 	unsigned int mask = (unsigned long) _table & 3;
 	void *table = (void *)((unsigned long) _table ^ mask);
@@ -316,67 +316,6 @@ static void __tlb_remove_table(void *_ta
 	}
 }
 
-static void tlb_remove_table_smp_sync(void *arg)
-{
-	/* Simply deliver the interrupt */
-}
-
-static void tlb_remove_table_one(void *table)
-{
-	/*
-	 * This isn't an RCU grace period and hence the page-tables cannot be
-	 * assumed to be actually RCU-freed.
-	 *
-	 * It is however sufficient for software page-table walkers that rely
-	 * on IRQ disabling. See the comment near struct mmu_table_batch.
-	 */
-	smp_call_function(tlb_remove_table_smp_sync, NULL, 1);
-	__tlb_remove_table(table);
-}
-
-static void tlb_remove_table_rcu(struct rcu_head *head)
-{
-	struct mmu_table_batch *batch;
-	int i;
-
-	batch = container_of(head, struct mmu_table_batch, rcu);
-
-	for (i = 0; i < batch->nr; i++)
-		__tlb_remove_table(batch->tables[i]);
-
-	free_page((unsigned long)batch);
-}
-
-void tlb_table_flush(struct mmu_gather *tlb)
-{
-	struct mmu_table_batch **batch = &tlb->batch;
-
-	if (*batch) {
-		call_rcu(&(*batch)->rcu, tlb_remove_table_rcu);
-		*batch = NULL;
-	}
-}
-
-void tlb_remove_table(struct mmu_gather *tlb, void *table)
-{
-	struct mmu_table_batch **batch = &tlb->batch;
-
-	tlb->mm->context.flush_mm = 1;
-	if (*batch == NULL) {
-		*batch = (struct mmu_table_batch *)
-			__get_free_page(GFP_NOWAIT | __GFP_NOWARN);
-		if (*batch == NULL) {
-			__tlb_flush_mm_lazy(tlb->mm);
-			tlb_remove_table_one(table);
-			return;
-		}
-		(*batch)->nr = 0;
-	}
-	(*batch)->tables[(*batch)->nr++] = table;
-	if ((*batch)->nr == MAX_TABLE_BATCH)
-		tlb_flush_mmu(tlb);
-}
-
 /*
  * Base infrastructure required to generate basic asces, region, segment,
  * and page tables that do not make use of enhanced features like EDAT1.


