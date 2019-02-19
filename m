Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1D32DC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 10:33:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C464120818
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 10:33:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="SIfwrom3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C464120818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 114048E000D; Tue, 19 Feb 2019 05:33:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 09F968E0005; Tue, 19 Feb 2019 05:33:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E0D358E000E; Tue, 19 Feb 2019 05:33:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id A12CC8E0005
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 05:33:04 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id q184so3601500itd.6
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 02:33:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:user-agent:date:from
         :to:cc:subject:references:mime-version;
        bh=V0TX/f/KtNWlhMwyKupZ8SV8wHyavqNWTt2wqgtfDyM=;
        b=m3FoLYk4AUFqhdpKDWewO6KfBf0ZNna4roIutrRtW4JV4T9TZ2Lkav/E2pe7eu4wwh
         /W91ZuJx/L4YLafGFRUk0u2RCUj3YO4954hTaYVV6T3YdKX0GZbPwdPMcNAJHvkYdhrK
         Bsau+ox0QL/z3VscUFKzQsTjlvf/G/0DuEfqlFcT5HyRRtyJyriFjX5HqeLduVSchJzF
         rSVP/V6V+Zis/GmDKOTJhPh1A40BnouIDmuhcUtSQWhiI2Al/M2N/l5qbthn+R4QVeRl
         z14l+QfmLP5AldEbXbOrEIfSebiQ8JGIUQG2NvsPT1Y9W7NUe2/tF/5S2FbGSwHEWHgW
         +Iwg==
X-Gm-Message-State: AHQUAubbIcuvG90dtLvqEZ2eXiauskSSF0n8sH3W686c6p4jp/VKNcQM
	T9pLXeabGhCjlTqHqfLijs0y9jswJt4lklBnZgiJMqdWSfpUJlKCcJrUHyCyY03IsiPegG3l2Gc
	/6Q2k2CI1jHKcusILdhPYcBfWqD/t4V8wq747A0kHBXXnV1Avnjl2mvu1hl8kn4btDA==
X-Received: by 2002:a5e:a60f:: with SMTP id q15mr16999378ioi.140.1550572384448;
        Tue, 19 Feb 2019 02:33:04 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib74F302Q9qrTyzPbSScVlUi/KKQ+v24cbBiREkLKUBiRTP465uf80C/4whlnz7/nRm55YM
X-Received: by 2002:a5e:a60f:: with SMTP id q15mr16999324ioi.140.1550572383627;
        Tue, 19 Feb 2019 02:33:03 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550572383; cv=none;
        d=google.com; s=arc-20160816;
        b=zzDri4zikNzjkLkclxQxApyFdHA06b7aPggRiSP4nOytpHkf+JICntSPhKfv4Gxznz
         Oq0v06v6ikcugTa0hqTWmwIgSr1NEuwzX22EnMIdUWskIz7ojzHQByRdHqwChIfzLcf8
         D122XGiK5U1NJjHqdZ9zA560U4qotN+9DqhUHTbQWyHA4KJsnP+hDNtB7cdZimXIQ5Rq
         ouCSsM0QpnX4LK/ywPFOLTx2U2ug8XmWt9JRV+7xRUv2yuVJxFEWDIc4nW2I1gncXD95
         Jkf18d+ydiCWRqrPDdjLWBXWyRvC2tww5cuzG7kJ7K9Qp6eDKZq20O4hi4P1NJN55n+U
         ovCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id:dkim-signature;
        bh=V0TX/f/KtNWlhMwyKupZ8SV8wHyavqNWTt2wqgtfDyM=;
        b=L8p+OwejRFZqTDPwDG4Py7YcpfgmHIfEAVUs+mMy6abkP1XHIdSQ0voUVGjKKJ2TrN
         Y5ZlEGz4oh7hc7k1ajBgsIbiJQiENH6aAIMHLOfdxOKLd5OIcnznu8XyN34xwR2/S9Dq
         ht8tqobL/12fKbuCqv8MDObUTETXOmhH+sMCEo7aprNpzK5GnsvsyFGYDWyjTrhW8fWy
         AOyrvHn/ks9lgzM6Fqkzfuv7fK1UAVXflKqWfi6M2e4tEgKtI7OSQbPZOMlevX4YztwM
         9o00o5sDYo3g86T3T0lkRCVZxE7kmJ9D1bH+T7SsTkHIk1gyYpYJB3xgwoJzHaoCHUJe
         3FIA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=SIfwrom3;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id h13si1058492itj.69.2019.02.19.02.33.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 02:33:03 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=SIfwrom3;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Type:MIME-Version:References:
	Subject:Cc:To:From:Date:Message-Id:Sender:Reply-To:Content-Transfer-Encoding:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=V0TX/f/KtNWlhMwyKupZ8SV8wHyavqNWTt2wqgtfDyM=; b=SIfwrom3v2nHsuKsYhUOG0SKab
	jb6QGizrwe2d7JlbxgCw+LRNgAsRaDClw/UfCxVi0OXpnMff0bqYwwpDBdy6MqcEIzqdY1DIb7f2y
	zLeXGDAm++tCNxJuxTxQOYm3fvDXRdqsQ567ouApiB6LlzKoB/IFYZWmwcTHFATWRsce8kHSONGMV
	SO1WeW+gidPBqUAoMHPOah48QVYUZ/KFtg31qSiaYwdt29icvV8ToLGhxQqBt2Z0MKzrBPJVFORIU
	INOZvD2WYBfB7rG1A69pV8B5+N+Fj/LkQPBrYwFXXx8VAgA5Ie4HCAgIKScwIgtNFZywCpX/eeBlq
	LGEDzkOQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gw2hp-0000dx-9V; Tue, 19 Feb 2019 10:32:53 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 0)
	id 795F8285205A2; Tue, 19 Feb 2019 11:32:48 +0100 (CET)
Message-Id: <20190219103233.752135076@infradead.org>
User-Agent: quilt/0.65
Date: Tue, 19 Feb 2019 11:32:03 +0100
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
Subject: [PATCH v6 15/18] asm-generic/tlb: Remove arch_tlb*_mmu()
References: <20190219103148.192029670@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Now that all architectures are converted to the generic code, remove
the arch hooks.

Acked-by: Will Deacon <will.deacon@arm.com>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 mm/mmu_gather.c |   93 +++++++++++++++++++++++++-------------------------------
 1 file changed, 42 insertions(+), 51 deletions(-)

--- a/mm/mmu_gather.c
+++ b/mm/mmu_gather.c
@@ -93,33 +93,6 @@ bool __tlb_remove_page_size(struct mmu_g
 
 #endif /* HAVE_MMU_GATHER_NO_GATHER */
 
-void arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
-				unsigned long start, unsigned long end)
-{
-	tlb->mm = mm;
-
-	/* Is it from 0 to ~0? */
-	tlb->fullmm     = !(start | (end+1));
-
-#ifndef CONFIG_HAVE_MMU_GATHER_NO_GATHER
-	tlb->need_flush_all = 0;
-	tlb->local.next = NULL;
-	tlb->local.nr   = 0;
-	tlb->local.max  = ARRAY_SIZE(tlb->__pages);
-	tlb->active     = &tlb->local;
-	tlb->batch_count = 0;
-#endif
-
-#ifdef CONFIG_HAVE_RCU_TABLE_FREE
-	tlb->batch = NULL;
-#endif
-#ifdef CONFIG_HAVE_MMU_GATHER_PAGE_SIZE
-	tlb->page_size = 0;
-#endif
-
-	__tlb_reset_range(tlb);
-}
-
 void tlb_flush_mmu_free(struct mmu_gather *tlb)
 {
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
@@ -136,27 +109,6 @@ void tlb_flush_mmu(struct mmu_gather *tl
 	tlb_flush_mmu_free(tlb);
 }
 
-/* tlb_finish_mmu
- *	Called at the end of the shootdown operation to free up any resources
- *	that were required.
- */
-void arch_tlb_finish_mmu(struct mmu_gather *tlb,
-		unsigned long start, unsigned long end, bool force)
-{
-	if (force) {
-		__tlb_reset_range(tlb);
-		__tlb_adjust_range(tlb, start, end - start);
-	}
-
-	tlb_flush_mmu(tlb);
-
-	/* keep the page table cache within bounds */
-	check_pgt_cache();
-#ifndef CONFIG_HAVE_MMU_GATHER_NO_GATHER
-	tlb_batch_list_free(tlb);
-#endif
-}
-
 #endif /* HAVE_GENERIC_MMU_GATHER */
 
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
@@ -258,10 +210,40 @@ void tlb_remove_table(struct mmu_gather
 void tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
 			unsigned long start, unsigned long end)
 {
-	arch_tlb_gather_mmu(tlb, mm, start, end);
+	tlb->mm = mm;
+
+	/* Is it from 0 to ~0? */
+	tlb->fullmm     = !(start | (end+1));
+
+#ifndef CONFIG_HAVE_MMU_GATHER_NO_GATHER
+	tlb->need_flush_all = 0;
+	tlb->local.next = NULL;
+	tlb->local.nr   = 0;
+	tlb->local.max  = ARRAY_SIZE(tlb->__pages);
+	tlb->active     = &tlb->local;
+	tlb->batch_count = 0;
+#endif
+
+#ifdef CONFIG_HAVE_RCU_TABLE_FREE
+	tlb->batch = NULL;
+#endif
+#ifdef CONFIG_HAVE_MMU_GATHER_PAGE_SIZE
+	tlb->page_size = 0;
+#endif
+
+	__tlb_reset_range(tlb);
 	inc_tlb_flush_pending(tlb->mm);
 }
 
+/**
+ * tlb_finish_mmu - finish an mmu_gather structure
+ * @tlb: the mmu_gather structure to finish
+ * @start: start of the region that will be removed from the page-table
+ * @end: end of the region that will be removed from the page-table
+ *
+ * Called at the end of the shootdown operation to free up any resources that
+ * were required.
+ */
 void tlb_finish_mmu(struct mmu_gather *tlb,
 		unsigned long start, unsigned long end)
 {
@@ -272,8 +254,17 @@ void tlb_finish_mmu(struct mmu_gather *t
 	 * the TLB by observing pte_none|!pte_dirty, for example so flush TLB
 	 * forcefully if we detect parallel PTE batching threads.
 	 */
-	bool force = mm_tlb_flush_nested(tlb->mm);
+	if (mm_tlb_flush_nested(tlb->mm)) {
+		__tlb_reset_range(tlb);
+		__tlb_adjust_range(tlb, start, end - start);
+	}
 
-	arch_tlb_finish_mmu(tlb, start, end, force);
+	tlb_flush_mmu(tlb);
+
+	/* keep the page table cache within bounds */
+	check_pgt_cache();
+#ifndef CONFIG_HAVE_MMU_GATHER_NO_GATHER
+	tlb_batch_list_free(tlb);
+#endif
 	dec_tlb_flush_pending(tlb->mm);
 }


