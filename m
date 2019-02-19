Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6372DC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 10:33:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 12C3120818
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 10:33:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="t11hqDFf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 12C3120818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E32878E0008; Tue, 19 Feb 2019 05:32:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DBD5A8E0007; Tue, 19 Feb 2019 05:32:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB0E98E0008; Tue, 19 Feb 2019 05:32:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2F6368E0009
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 05:32:58 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id e2so4433526pln.12
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 02:32:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:user-agent:date:from
         :to:cc:subject:references:mime-version;
        bh=TN5RXNcFDEGbWABVLmVNC8x3PmXlqXdoY5MjcRf6CAs=;
        b=Q3eEDAJco83SBUK2RQSpCuT+gATw6hUi/kBLWKlN2tAbZshnx9IgNNnTaxzXMvH5aV
         MyvkHmrvyw2OptjQ/SfCvAKfTQI+1oM+SAlo40pjpShtG81+QN8HLjkhe9uQhGchrlnR
         hKzCo+DYOxj2LGV3pJnhp5ZPuRrWFwMe7xvDFtI6jnCyTsNGMs1DcEA2/+AO2PQ52PV+
         SviLA7PdbkOm0PbkR1MnIxbJWjB+kyHTxOPl9CB+joc0FUT0zKkqnLVhjtretb7yAUnf
         VINgqMHmqSSpC0bNGwcuh9pFBaveaLM8AON0gSMJ52d2OKW+403Nzu8sCIbkIfboGhOx
         aBdA==
X-Gm-Message-State: AHQUAuZE/mapWrmyldtTPmJanHpBLVEqVyC0/9IfgxXl0QFnGDp3CyRn
	2YPhXVTp7UL+kTWcKzY4lhqZO4foctEQfieM61AaHzuaENDojqi+f1u63+k/8Q0SfUsVDPdeQzD
	vdp1YHtUduoxYHKDfDsxQTq73imjRIIRxhIIkng/1F4Xm/63aSF+wvgJPfjfWcoRy/Q==
X-Received: by 2002:a17:902:3283:: with SMTP id z3mr30525635plb.76.1550572377850;
        Tue, 19 Feb 2019 02:32:57 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ4bVB7qurOqhyfAvyBgH2PBLHWlePL1SnVvdHT1jai+swtxg3bpn1uaV0rm2ljxZOjel0a
X-Received: by 2002:a17:902:3283:: with SMTP id z3mr30525554plb.76.1550572376786;
        Tue, 19 Feb 2019 02:32:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550572376; cv=none;
        d=google.com; s=arc-20160816;
        b=0TySyjeoySiEnvtfl6yM46V8aFLkOKyGkdvXuKzvrnAKs/EKMjtbZmYxO7EjBbdv9o
         HH7SOprzlBoOphoL8admFaRLJahIxbEhIl6vl5n5m9hZxs+NUgGKpoTulZ88/2gAKtmt
         McDYhTtmGRAMsWwFPPV7Id3vKPB4bmor6RhZfyHLSRNRg+fjmEDG7degkCxgOsgFSL/N
         vMEuY987RLZcY//t2VSHkXozMwObobD3W1+iWFMipvfzWT7hxReZT/CBtsTcmnNu4d7q
         Np0ykkNdUUnmQ/cByjoEXx+Jc52XwDMgrGuQpKyevH+bw/ZViQw7us9LwkdccgRFcq23
         +abQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id:dkim-signature;
        bh=TN5RXNcFDEGbWABVLmVNC8x3PmXlqXdoY5MjcRf6CAs=;
        b=XY7l460fAC6Zegk0b8bUVYPVYw6Lfcpj8ereehEKe5XyUtFyQGxnv7hys78Rd9RhCi
         sfTnTwI8JEV6+MM2A9jHVTMjd0/VSMYpndu/+XBjgyAfdAIaLtAcxRM6Mf7GeqwEitRG
         h0Lim7byDp9BNnaTPDkLoRgzRyCt+LTtBrgCNX34g4FmbVT5Gdb+wGQm4xBDnVJKN7vA
         By7Yk6TBU+cnxf81f7PIeQ6AemDKg66wmvmTq7m4Kpo0sZQDJ8Xe8ry1QBatU3ii/QE6
         yCs2NBX82tamG5nixOC3YiHb+X/DahPtoGREUD9yNdATE/0Zq0JWmwNmwNIj9CeZMwOD
         WD4w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=t11hqDFf;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a5si14472141pgt.408.2019.02.19.02.32.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 02:32:56 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=t11hqDFf;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Type:MIME-Version:References:
	Subject:Cc:To:From:Date:Message-Id:Sender:Reply-To:Content-Transfer-Encoding:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=TN5RXNcFDEGbWABVLmVNC8x3PmXlqXdoY5MjcRf6CAs=; b=t11hqDFfI3p46LQLOtEQH0lKGJ
	Az8qsd9R/MlPa/LVrdrqS+luhzuoWMwl68zDGBHhk5LgiACyb0ZdmpIp/qnKl366z0AEwGQH/k0mU
	ae9qdVDBIraTosQQygH0fcmqOTTPVFYrMJuNu877r+SCcaF34MlxVgonw0183nh/AHUphvx+xKuUV
	34jKs9SARhwr1VvLMhO6OPJtNvSL+eA7LE7DY1qUBgZb71aVz9U7+Rt1aWU0iOTC5K7Dx4hfpOVHG
	vE/dalC3yfqpMquFb+46RuPcPD7o3kgGhDigLB6/UmO9y1LncQZhQsDIR1cNl0NY+J7xY/txVLOBs
	P+SKR3Yw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gw2ho-0006ZV-MH; Tue, 19 Feb 2019 10:32:52 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 0)
	id 7233C285205A0; Tue, 19 Feb 2019 11:32:48 +0100 (CET)
Message-Id: <20190219103233.633310832@infradead.org>
User-Agent: quilt/0.65
Date: Tue, 19 Feb 2019 11:32:01 +0100
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
Subject: [PATCH v6 13/18] asm-generic/tlb: Introduce HAVE_MMU_GATHER_NO_GATHER
References: <20190219103148.192029670@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add the Kconfig option HAVE_MMU_GATHER_NO_GATHER to the generic
mmu_gather code. If the option is set the mmu_gather will not
track individual pages for delayed page free anymore. A platform
that enables the option needs to provide its own implementation
of the __tlb_remove_page_size function to free pages.

Cc: npiggin@gmail.com
Cc: heiko.carstens@de.ibm.com
Cc: will.deacon@arm.com
Cc: aneesh.kumar@linux.vnet.ibm.com
Cc: akpm@linux-foundation.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux@armlinux.org.uk
Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Link: http://lkml.kernel.org/r/20180918125151.31744-2-schwidefsky@de.ibm.com
---
 arch/Kconfig              |    3 +
 include/asm-generic/tlb.h |    9 +++
 mm/mmu_gather.c           |  107 +++++++++++++++++++++++++---------------------
 3 files changed, 70 insertions(+), 49 deletions(-)

--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -368,6 +368,9 @@ config HAVE_RCU_TABLE_NO_INVALIDATE
 config HAVE_MMU_GATHER_PAGE_SIZE
 	bool
 
+config HAVE_MMU_GATHER_NO_GATHER
+	bool
+
 config ARCH_HAVE_NMI_SAFE_CMPXCHG
 	bool
 
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -184,6 +184,7 @@ extern void tlb_remove_table(struct mmu_
 
 #endif
 
+#ifndef CONFIG_HAVE_MMU_GATHER_NO_GATHER
 /*
  * If we can't allocate a page to make a big batch of page pointers
  * to work on, then just handle a few from the on-stack structure.
@@ -208,6 +209,10 @@ struct mmu_gather_batch {
  */
 #define MAX_GATHER_BATCH_COUNT	(10000UL/MAX_GATHER_BATCH)
 
+extern bool __tlb_remove_page_size(struct mmu_gather *tlb, struct page *page,
+				   int page_size);
+#endif
+
 /*
  * struct mmu_gather is an opaque type used by the mm code for passing around
  * any data needed by arch specific code for tlb_remove_page.
@@ -254,6 +259,7 @@ struct mmu_gather {
 
 	unsigned int		batch_count;
 
+#ifndef CONFIG_HAVE_MMU_GATHER_NO_GATHER
 	struct mmu_gather_batch *active;
 	struct mmu_gather_batch	local;
 	struct page		*__pages[MMU_GATHER_BUNDLE];
@@ -261,6 +267,7 @@ struct mmu_gather {
 #ifdef CONFIG_HAVE_MMU_GATHER_PAGE_SIZE
 	unsigned int page_size;
 #endif
+#endif
 };
 
 void arch_tlb_gather_mmu(struct mmu_gather *tlb,
@@ -269,8 +276,6 @@ void tlb_flush_mmu(struct mmu_gather *tl
 void arch_tlb_finish_mmu(struct mmu_gather *tlb,
 			 unsigned long start, unsigned long end, bool force);
 void tlb_flush_mmu_free(struct mmu_gather *tlb);
-extern bool __tlb_remove_page_size(struct mmu_gather *tlb, struct page *page,
-				   int page_size);
 
 static inline void __tlb_adjust_range(struct mmu_gather *tlb,
 				      unsigned long address,
--- a/mm/mmu_gather.c
+++ b/mm/mmu_gather.c
@@ -13,6 +13,8 @@
 
 #ifdef HAVE_GENERIC_MMU_GATHER
 
+#ifndef CONFIG_HAVE_MMU_GATHER_NO_GATHER
+
 static bool tlb_next_batch(struct mmu_gather *tlb)
 {
 	struct mmu_gather_batch *batch;
@@ -41,6 +43,56 @@ static bool tlb_next_batch(struct mmu_ga
 	return true;
 }
 
+static void tlb_batch_pages_flush(struct mmu_gather *tlb)
+{
+	struct mmu_gather_batch *batch;
+
+	for (batch = &tlb->local; batch && batch->nr; batch = batch->next) {
+		free_pages_and_swap_cache(batch->pages, batch->nr);
+		batch->nr = 0;
+	}
+	tlb->active = &tlb->local;
+}
+
+static void tlb_batch_list_free(struct mmu_gather *tlb)
+{
+	struct mmu_gather_batch *batch, *next;
+
+	for (batch = tlb->local.next; batch; batch = next) {
+		next = batch->next;
+		free_pages((unsigned long)batch, 0);
+	}
+	tlb->local.next = NULL;
+}
+
+bool __tlb_remove_page_size(struct mmu_gather *tlb, struct page *page, int page_size)
+{
+	struct mmu_gather_batch *batch;
+
+	VM_BUG_ON(!tlb->end);
+
+#ifdef CONFIG_HAVE_MMU_GATHER_PAGE_SIZE
+	VM_WARN_ON(tlb->page_size != page_size);
+#endif
+
+	batch = tlb->active;
+	/*
+	 * Add the page and check if we are full. If so
+	 * force a flush.
+	 */
+	batch->pages[batch->nr++] = page;
+	if (batch->nr == batch->max) {
+		if (!tlb_next_batch(tlb))
+			return true;
+		batch = tlb->active;
+	}
+	VM_BUG_ON_PAGE(batch->nr > batch->max, page);
+
+	return false;
+}
+
+#endif /* HAVE_MMU_GATHER_NO_GATHER */
+
 void arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
 				unsigned long start, unsigned long end)
 {
@@ -48,12 +100,15 @@ void arch_tlb_gather_mmu(struct mmu_gath
 
 	/* Is it from 0 to ~0? */
 	tlb->fullmm     = !(start | (end+1));
+
+#ifndef CONFIG_HAVE_MMU_GATHER_NO_GATHER
 	tlb->need_flush_all = 0;
 	tlb->local.next = NULL;
 	tlb->local.nr   = 0;
 	tlb->local.max  = ARRAY_SIZE(tlb->__pages);
 	tlb->active     = &tlb->local;
 	tlb->batch_count = 0;
+#endif
 
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	tlb->batch = NULL;
@@ -67,16 +122,12 @@ void arch_tlb_gather_mmu(struct mmu_gath
 
 void tlb_flush_mmu_free(struct mmu_gather *tlb)
 {
-	struct mmu_gather_batch *batch;
-
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	tlb_table_flush(tlb);
 #endif
-	for (batch = &tlb->local; batch && batch->nr; batch = batch->next) {
-		free_pages_and_swap_cache(batch->pages, batch->nr);
-		batch->nr = 0;
-	}
-	tlb->active = &tlb->local;
+#ifndef CONFIG_HAVE_MMU_GATHER_NO_GATHER
+	tlb_batch_pages_flush(tlb);
+#endif
 }
 
 void tlb_flush_mmu(struct mmu_gather *tlb)
@@ -92,8 +143,6 @@ void tlb_flush_mmu(struct mmu_gather *tl
 void arch_tlb_finish_mmu(struct mmu_gather *tlb,
 		unsigned long start, unsigned long end, bool force)
 {
-	struct mmu_gather_batch *batch, *next;
-
 	if (force) {
 		__tlb_reset_range(tlb);
 		__tlb_adjust_range(tlb, start, end - start);
@@ -103,45 +152,9 @@ void arch_tlb_finish_mmu(struct mmu_gath
 
 	/* keep the page table cache within bounds */
 	check_pgt_cache();
-
-	for (batch = tlb->local.next; batch; batch = next) {
-		next = batch->next;
-		free_pages((unsigned long)batch, 0);
-	}
-	tlb->local.next = NULL;
-}
-
-/* __tlb_remove_page
- *	Must perform the equivalent to __free_pte(pte_get_and_clear(ptep)), while
- *	handling the additional races in SMP caused by other CPUs caching valid
- *	mappings in their TLBs. Returns the number of free page slots left.
- *	When out of page slots we must call tlb_flush_mmu().
- *returns true if the caller should flush.
- */
-bool __tlb_remove_page_size(struct mmu_gather *tlb, struct page *page, int page_size)
-{
-	struct mmu_gather_batch *batch;
-
-	VM_BUG_ON(!tlb->end);
-
-#ifdef CONFIG_HAVE_MMU_GATHER_PAGE_SIZE
-	VM_WARN_ON(tlb->page_size != page_size);
+#ifndef CONFIG_HAVE_MMU_GATHER_NO_GATHER
+	tlb_batch_list_free(tlb);
 #endif
-
-	batch = tlb->active;
-	/*
-	 * Add the page and check if we are full. If so
-	 * force a flush.
-	 */
-	batch->pages[batch->nr++] = page;
-	if (batch->nr == batch->max) {
-		if (!tlb_next_batch(tlb))
-			return true;
-		batch = tlb->active;
-	}
-	VM_BUG_ON_PAGE(batch->nr > batch->max, page);
-
-	return false;
 }
 
 #endif /* HAVE_GENERIC_MMU_GATHER */


