Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2CBB9C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 10:33:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3D6620818
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 10:33:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="p61e+kcQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3D6620818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 29C568E000A; Tue, 19 Feb 2019 05:32:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 223878E0007; Tue, 19 Feb 2019 05:32:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A2868E000A; Tue, 19 Feb 2019 05:32:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A4B0E8E0005
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 05:32:58 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id y66so15923485pfg.16
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 02:32:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:user-agent:date:from
         :to:cc:subject:references:mime-version;
        bh=xnijaTD9/LTfaSe8x9OwrOkkSMxAqrZQqnN4cMRi0xo=;
        b=nevF6E7VvPd48pIwqagpsefJZ1KjOs3gydrliS6pNUMmRcJfHQhZK8WZrW7+adZnhs
         I0UoJAiRwl6RoQx0qDLwn+6CmXe6aCzpxxjWGetNKAqM+amHQ7iCcaUpB+GrHDWi0MK4
         hXWoPwRJ4wLgdUMmO/+Iu56fg5ZbsVGTiwJKWDJ3hps4qo8vEwycnkwGHOnCCRM3ly0t
         x4pAe3EbyRxQ4adtcefLl68efZO7q+uCrchWd0KR7qZcS7++Fq7xn8vyfBj8zTaS/gfr
         5nY6hbuhbYjQIHSHz2Usv9q6+4me2ESajIsRMLu2AveNHl+X7LiU6pMRAb26nV0dOlOY
         pQSg==
X-Gm-Message-State: AHQUAubrX1/GRYWpeCpBI1a5etBZoe3MeAEdzz7EWUoGZIEdltpMfwCm
	38E8OJJ4FoHuYFrIVMZgTcVl7qwset1oDVE64fXQy/TA2Z3MkxUlD8v1zfFf/dfV9MlehUge6lc
	hMrKjUYnc+AoGYWAd5ioBsXAum/GQBLW3Xf8+18VjqOz93LyGkgh8ygPUeRa9hqnB4Q==
X-Received: by 2002:a17:902:e409:: with SMTP id ci9mr6904209plb.221.1550572378319;
        Tue, 19 Feb 2019 02:32:58 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbVxJdH29dBz55ckJi7dRRGaqn3lJ58HdoMI3VVrBMvpz5bAKsesm0faedIZMh9ZKwcou3G
X-Received: by 2002:a17:902:e409:: with SMTP id ci9mr6904168plb.221.1550572377615;
        Tue, 19 Feb 2019 02:32:57 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550572377; cv=none;
        d=google.com; s=arc-20160816;
        b=IzALHfSo/c6L/ykzJb5aXOaeXlTY2JZ3j97XIK/e30DT+tBT9DSEBjRCRWhrcQ413f
         IL0NxVQoUINqzqUOuggpycyBJsn2d3O+A4Vs3+taUPdfoAEpPrsO8C3jeqvw/4Ptf8bq
         R0cLRE25RUWnB7jUBsUHzav6kHB+aI/9h/7K89HPhdiZVyl9AzgRg9VnWdt6K2EsgJV1
         AGSuhOiGAwoqiqawA5XByxqdaYmsK5OeYLdHQVFQLyMDy4XeoRJfGMllItQ0miT3FElx
         FVw5VfdNkkCEijPmaVF44Xj41oTr0U9dlVO3aciVBIUdr+kCNMok+UX0aGXS3M87OOhd
         9vag==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id:dkim-signature;
        bh=xnijaTD9/LTfaSe8x9OwrOkkSMxAqrZQqnN4cMRi0xo=;
        b=VimId2fIjPAd0pIh+O1OlUqZdiL2hgzcs1KTrTlyI2gu1tZ4EAZFKE24OehhU3KWsW
         OiCgue/ntlxYq5dR9Nf4NsOz6O8nTRFCoZIgusL1xrYMjmBWZ2WIEGPIRBpRF3h8ccH3
         pIWXAzC8oAgtIIzeJJj5R7iI8k6+QE/3c7aoW63QVFB6IItH8wjmbl61E5yYl1k36qtz
         rvOf6v7CXqZGLWtYcUyGotNk9Z2mgoruaIK7VJXWP5QGkB83pMSnbq5tODlnsLbuPU1m
         I9gOMTvZEXseSvuSXCkk8rms7qCDL0Ptpt57aiXtr/QtHDCQGVCuWJjn7P5VT9QcbnSR
         YwzA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=p61e+kcQ;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 123si15454705pfx.109.2019.02.19.02.32.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 02:32:57 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=p61e+kcQ;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Type:MIME-Version:References:
	Subject:Cc:To:From:Date:Message-Id:Sender:Reply-To:Content-Transfer-Encoding:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=xnijaTD9/LTfaSe8x9OwrOkkSMxAqrZQqnN4cMRi0xo=; b=p61e+kcQCih0IRI1ErTzuM4kht
	Uh20OG4wyZhC/0sjvGGI8snWLIySrUjTH0eXRF/kuCOeStMlOuhb1cSq5ZUzAyLxpXbw/JO+ju5Lq
	AS8Kd2fO9l4QgNBDTG66PEz0pMue0RJ+fmKzJVgQHWSVupOQejCwbVjeHFej+M1v0RZde+2TEDw09
	g2iz5RjFLUxXhGzmP1sET6oLXhDe90E3xcZaJrnsXCKaBk87FyxIfTn76CJuyiyg4MKM1nrsWei0z
	tTlafjMFlfeacNBOmMhsngudoOcFfKjGGkfZefiM4CEZQJrC4sUE55eOIIcbqgIwVpt+yUhrLoseH
	HP65Z8rw==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gw2hp-0006Zi-Je; Tue, 19 Feb 2019 10:32:53 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 0)
	id 84DF6285205A5; Tue, 19 Feb 2019 11:32:48 +0100 (CET)
Message-Id: <20190219103233.927987010@infradead.org>
User-Agent: quilt/0.65
Date: Tue, 19 Feb 2019 11:32:06 +0100
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
Subject: [PATCH v6 18/18] asm-generic/tlb: Remove tlb_table_flush()
References: <20190219103148.192029670@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There are no external users of this API (nor should there be); remove it.

Acked-by: Will Deacon <will.deacon@arm.com>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 include/asm-generic/tlb.h |    1 -
 mm/mmu_gather.c           |   34 +++++++++++++++++-----------------
 2 files changed, 17 insertions(+), 18 deletions(-)

--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -174,7 +174,6 @@ struct mmu_table_batch {
 #define MAX_TABLE_BATCH		\
 	((PAGE_SIZE - sizeof(struct mmu_table_batch)) / sizeof(void *))
 
-extern void tlb_table_flush(struct mmu_gather *tlb);
 extern void tlb_remove_table(struct mmu_gather *tlb, void *table);
 
 #endif
--- a/mm/mmu_gather.c
+++ b/mm/mmu_gather.c
@@ -91,22 +91,6 @@ bool __tlb_remove_page_size(struct mmu_g
 
 #endif /* HAVE_MMU_GATHER_NO_GATHER */
 
-static void tlb_flush_mmu_free(struct mmu_gather *tlb)
-{
-#ifdef CONFIG_HAVE_RCU_TABLE_FREE
-	tlb_table_flush(tlb);
-#endif
-#ifndef CONFIG_HAVE_MMU_GATHER_NO_GATHER
-	tlb_batch_pages_flush(tlb);
-#endif
-}
-
-void tlb_flush_mmu(struct mmu_gather *tlb)
-{
-	tlb_flush_mmu_tlbonly(tlb);
-	tlb_flush_mmu_free(tlb);
-}
-
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 
 /*
@@ -159,7 +143,7 @@ static void tlb_remove_table_rcu(struct
 	free_page((unsigned long)batch);
 }
 
-void tlb_table_flush(struct mmu_gather *tlb)
+static void tlb_table_flush(struct mmu_gather *tlb)
 {
 	struct mmu_table_batch **batch = &tlb->batch;
 
@@ -191,6 +175,22 @@ void tlb_remove_table(struct mmu_gather
 
 #endif /* CONFIG_HAVE_RCU_TABLE_FREE */
 
+static void tlb_flush_mmu_free(struct mmu_gather *tlb)
+{
+#ifdef CONFIG_HAVE_RCU_TABLE_FREE
+	tlb_table_flush(tlb);
+#endif
+#ifndef CONFIG_HAVE_MMU_GATHER_NO_GATHER
+	tlb_batch_pages_flush(tlb);
+#endif
+}
+
+void tlb_flush_mmu(struct mmu_gather *tlb)
+{
+	tlb_flush_mmu_tlbonly(tlb);
+	tlb_flush_mmu_free(tlb);
+}
+
 /**
  * tlb_gather_mmu - initialize an mmu_gather structure for page-table tear-down
  * @tlb: the mmu_gather structure to initialize


