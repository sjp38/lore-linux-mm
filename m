Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5520DC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 10:33:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 03D1720818
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 10:33:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="K8MTrczw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 03D1720818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB3A98E0009; Tue, 19 Feb 2019 05:32:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C5238E0007; Tue, 19 Feb 2019 05:32:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8424C8E0005; Tue, 19 Feb 2019 05:32:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2EDC18E0008
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 05:32:58 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id v82so15947453pfj.9
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 02:32:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:user-agent:date:from
         :to:cc:subject:references:mime-version;
        bh=Qgx3kgv+AkSn1Y+HQ6cCIZsGaoQ/+n1Kc3v/8+oaveQ=;
        b=kJ+TgmfGwhJNZO+5JuW9YKnnIPAeXDxjciAuZrevlIemVWjSJ3MOldX8mEdlSU3VoJ
         OdJl4kWJL+ROZl/JuFLdgEEYu1BVNvpwcJGtJdrv57nMRW2dXiBoGfNV+D1Cv2NE5qXM
         AVoQDOJMYVKiAYsaBfeZcoRd/7nM1sLq/lcUkmCG/gtv1PMPBOMcSQweZT7OKczxKFuB
         Yvo3VWn0NlIbqfgMTpyjRl2mw9pUSWZIYA0Q+o+7gbufrs5sh5dnF14ke/oMpnRKwRuy
         1Ib3YIpfjagYSi1JiuQlz6s9Kf7WlbCY6fvWK4+LTIkcWSd1vbzxTey4ThsF2QViP08c
         OBDg==
X-Gm-Message-State: AHQUAuZk9kNpmto/NnLzslGqS0wWX4wtHWOrlFjA73flJudUlF0FwiPo
	N6WtIG70BS2axD8p/r/oGDc2xaqI/ZqBS3mw6ADC61Bgu6WZt1IkJ9KJMLm2IsdPkjHAn0IFdpD
	ew31amCKJlMyS0SW1QQJMDZ0Am26mUP1jo0oTIo36zL+VXTM/KP2QrT+Jb9tIHM4gEw==
X-Received: by 2002:a63:c307:: with SMTP id c7mr1399250pgd.386.1550572377851;
        Tue, 19 Feb 2019 02:32:57 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYGy7EEEa9SJOeL7vN/MC0wp54B1/Sb4ZSbem0etcwCyASBT5RE6rMhkOmYrGQIVGLMTvFa
X-Received: by 2002:a63:c307:: with SMTP id c7mr1399193pgd.386.1550572376976;
        Tue, 19 Feb 2019 02:32:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550572376; cv=none;
        d=google.com; s=arc-20160816;
        b=mDIQ26tidvItFmWlvSXpHuJBRbp+C93gRFW4HMsnBAqMeZNjhgzdPvOVM2CjQh/lm1
         ojkiqU4YTAWoFANu1peZPB3Z0K78El0Oqx4QIXjsXB0Doel+5CmoAeEa9D/bcMxGEAyd
         hWjvKHn7Q3pDyd3dhu1YbgebDsebQGrH4bqgw49S8oLZ2QqM1iFThev+DT+YJnrd9OZ+
         865BLYcsqpqUtRU18l+h8vb3GXiy0kFSZG2UbarDD/Ju/J/4MhkZY4N9vkyDSZ4US3x0
         0ewEERT5JrnusoTpps9mw3tHqER3IXd2bGjpUquUNYnTR3OBP951ovUyK05HAo8TwqpI
         22rw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id:dkim-signature;
        bh=Qgx3kgv+AkSn1Y+HQ6cCIZsGaoQ/+n1Kc3v/8+oaveQ=;
        b=ClZ4PnpFzm6NheMrf65H+UG+fZ3c5fJLcryjdoyQaCQ0IMVHPFOOs1DtDWq5VllI/L
         XUXUlm5FUN3zhZ29THFyr2cat6nZd7BaI/tpcVJs6ye3KMeF+Fe9vntP1yeWKksBLmpP
         Ecaj+xxQLVEqN7Jkr/XDuIIy83Zga+YxIcbSzqDfnVUQGhwtisDpwefuI99f5FOWPxGR
         bfXpABxgJwgYUUDqOvHsPl4pDrQavYfPm8wa9Q69tCvHpdn6ulg30f6QqI7nuqLVjPVU
         eQbIM8vPEj713bip1Pmbn/fPdvTjV8NNZIKYW9eL8Usfv5jTFdzEl0YkddE7e+Lo4nC5
         ofcA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=K8MTrczw;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n10si15454869pgd.57.2019.02.19.02.32.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 02:32:56 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=K8MTrczw;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Type:MIME-Version:References:
	Subject:Cc:To:From:Date:Message-Id:Sender:Reply-To:Content-Transfer-Encoding:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=Qgx3kgv+AkSn1Y+HQ6cCIZsGaoQ/+n1Kc3v/8+oaveQ=; b=K8MTrczwuDeiPR67LXHwzw7mnw
	C8u4rtwpVXJtSiXDRRyOmN31uswGLWKM3Omb47jTJCx1tn2h2p8mLuaM4fiJxn0//VYKS8/ugH/Xi
	guqkV1RkjbpdcXeL+Px9hrzfLyafAr274HEt0+MFlJXQ737JQ6vcCqXYc1FqyhN/A8VaXgapGVUpJ
	f3YkDSyip+zhSl5w8n1oxDMDq84SU0m74yGYVtcuUTEMZVxSVTkyfIzfErV2pVgDduZEBc6/Z7BjN
	9EMSszlzX9IYda0/znC38dMO01Zu8pDqYMN/r1B81cSUh7xYf2WN42PIUfX/i7kVdYU78+ZAKdR/a
	tBNrv7DQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gw2ho-0006ZU-Md; Tue, 19 Feb 2019 10:32:52 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 0)
	id 6B1BC2852059E; Tue, 19 Feb 2019 11:32:48 +0100 (CET)
Message-Id: <20190219103233.502111627@infradead.org>
User-Agent: quilt/0.65
Date: Tue, 19 Feb 2019 11:31:59 +0100
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
 Richard Weinberger <richard@nod.at>
Subject: [PATCH v6 11/18] um/tlb: Convert to generic mmu_gather
References: <20190219103148.192029670@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Generic mmu_gather provides the simple flush_tlb_range() based range
tracking mmu_gather UM needs.

Cc: Will Deacon <will.deacon@arm.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@gmail.com>
Cc: Richard Weinberger <richard@nod.at>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/um/include/asm/tlb.h |  156 ----------------------------------------------
 1 file changed, 2 insertions(+), 154 deletions(-)

--- a/arch/um/include/asm/tlb.h
+++ b/arch/um/include/asm/tlb.h
@@ -2,160 +2,8 @@
 #ifndef __UM_TLB_H
 #define __UM_TLB_H
 
-#include <linux/pagemap.h>
-#include <linux/swap.h>
-#include <asm/percpu.h>
-#include <asm/pgalloc.h>
 #include <asm/tlbflush.h>
-
-#define tlb_start_vma(tlb, vma) do { } while (0)
-#define tlb_end_vma(tlb, vma) do { } while (0)
-#define tlb_flush(tlb) flush_tlb_mm((tlb)->mm)
-
-/* struct mmu_gather is an opaque type used by the mm code for passing around
- * any data needed by arch specific code for tlb_remove_page.
- */
-struct mmu_gather {
-	struct mm_struct	*mm;
-	unsigned int		need_flush; /* Really unmapped some ptes? */
-	unsigned long		start;
-	unsigned long		end;
-	unsigned int		fullmm; /* non-zero means full mm flush */
-};
-
-static inline void __tlb_remove_tlb_entry(struct mmu_gather *tlb, pte_t *ptep,
-					  unsigned long address)
-{
-	if (tlb->start > address)
-		tlb->start = address;
-	if (tlb->end < address + PAGE_SIZE)
-		tlb->end = address + PAGE_SIZE;
-}
-
-static inline void init_tlb_gather(struct mmu_gather *tlb)
-{
-	tlb->need_flush = 0;
-
-	tlb->start = TASK_SIZE;
-	tlb->end = 0;
-
-	if (tlb->fullmm) {
-		tlb->start = 0;
-		tlb->end = TASK_SIZE;
-	}
-}
-
-static inline void
-arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
-		unsigned long start, unsigned long end)
-{
-	tlb->mm = mm;
-	tlb->start = start;
-	tlb->end = end;
-	tlb->fullmm = !(start | (end+1));
-
-	init_tlb_gather(tlb);
-}
-
-extern void flush_tlb_mm_range(struct mm_struct *mm, unsigned long start,
-			       unsigned long end);
-
-static inline void
-tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
-{
-	flush_tlb_mm_range(tlb->mm, tlb->start, tlb->end);
-}
-
-static inline void
-tlb_flush_mmu_free(struct mmu_gather *tlb)
-{
-	init_tlb_gather(tlb);
-}
-
-static inline void
-tlb_flush_mmu(struct mmu_gather *tlb)
-{
-	if (!tlb->need_flush)
-		return;
-
-	tlb_flush_mmu_tlbonly(tlb);
-	tlb_flush_mmu_free(tlb);
-}
-
-/* arch_tlb_finish_mmu
- *	Called at the end of the shootdown operation to free up any resources
- *	that were required.
- */
-static inline void
-arch_tlb_finish_mmu(struct mmu_gather *tlb,
-		unsigned long start, unsigned long end, bool force)
-{
-	if (force) {
-		tlb->start = start;
-		tlb->end = end;
-		tlb->need_flush = 1;
-	}
-	tlb_flush_mmu(tlb);
-
-	/* keep the page table cache within bounds */
-	check_pgt_cache();
-}
-
-/* tlb_remove_page
- *	Must perform the equivalent to __free_pte(pte_get_and_clear(ptep)),
- *	while handling the additional races in SMP caused by other CPUs
- *	caching valid mappings in their TLBs.
- */
-static inline int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
-{
-	tlb->need_flush = 1;
-	free_page_and_swap_cache(page);
-	return false; /* avoid calling tlb_flush_mmu */
-}
-
-static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
-{
-	__tlb_remove_page(tlb, page);
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
-/**
- * tlb_remove_tlb_entry - remember a pte unmapping for later tlb invalidation.
- *
- * Record the fact that pte's were really umapped in ->need_flush, so we can
- * later optimise away the tlb invalidate.   This helps when userspace is
- * unmapping already-unmapped pages, which happens quite a lot.
- */
-#define tlb_remove_tlb_entry(tlb, ptep, address)		\
-	do {							\
-		tlb->need_flush = 1;				\
-		__tlb_remove_tlb_entry(tlb, ptep, address);	\
-	} while (0)
-
-#define tlb_remove_huge_tlb_entry(h, tlb, ptep, address)	\
-	tlb_remove_tlb_entry(tlb, ptep, address)
-
-static inline void tlb_change_page_size(struct mmu_gather *tlb, unsigned int page_size)
-{
-}
-
-#define pte_free_tlb(tlb, ptep, addr) __pte_free_tlb(tlb, ptep, addr)
-
-#define pud_free_tlb(tlb, pudp, addr) __pud_free_tlb(tlb, pudp, addr)
-
-#define pmd_free_tlb(tlb, pmdp, addr) __pmd_free_tlb(tlb, pmdp, addr)
-
-#define tlb_migrate_finish(mm) do {} while (0)
+#include <asm-generic/cacheflush.h>
+#include <asm-generic/tlb.h>
 
 #endif


