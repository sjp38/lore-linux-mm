Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0020C43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 10:33:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 998AA20818
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 10:33:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="XQc7367t"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 998AA20818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB3DA8E0010; Tue, 19 Feb 2019 05:33:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9CA538E0005; Tue, 19 Feb 2019 05:33:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8662A8E000F; Tue, 19 Feb 2019 05:33:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 58FF38E0005
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 05:33:05 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id v12so3547012itv.9
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 02:33:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:user-agent:date:from
         :to:cc:subject:references:mime-version;
        bh=ny/EJ5kQ9AxbXrrJC6i+uZEQstUYIWoSCsf99o3ZhwQ=;
        b=WRbGKpm+S/ZtyuePTCFLdKBhb2T+un4lP6Mg4/o5+QARZhrGjbx224e2mwv8s75F0U
         r+PnbkpnIwY9HqdT4Df+UX+i+8B4b0xs8MwfOWWNvpKm/ZzsV7EEL1WUR9JfaT9f3OTs
         32ACDd85tFCLKeVGqiCFjHstbP6yn9q0cwQ2QznGXRX4Q/cy9IjDlETG3DJvHNN7snF6
         AwWoIXVF1+w3pUFmR+D9Kz8C/vzRcugr2hH4PeD0LTGPKHZoG9h2LALmRtbf4TtC8cfa
         mKNz1E3/KSSllMRlj9uFNx5lVHJshSFAelLH6t983XiWfn/7efBjNwJNVALJJGY9romO
         gWHg==
X-Gm-Message-State: AHQUAuZ1CU/VFrds+ip2io52ZYHihLOrXfpCeTVTaAUawzuPL+yp8yJl
	TjhRLOav00CRvU9EipDnYEGIKuEWZ3uksDYCV0ifFw3XA3Sw94CIqTR+fLK7lSt61mL6+2L5Qpi
	+OXHEa1zpraMYnshnoDNGWxyBE32dgbRTCmK+sLcqYAczEHwMkHhyiUUS0jlWTKqEwA==
X-Received: by 2002:a5d:8198:: with SMTP id u24mr15811578ion.177.1550572385167;
        Tue, 19 Feb 2019 02:33:05 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYvCMduIZ1mVkCzFP2XBfBpmgmaLCp9iKqAtc4ES/qedfzA5BSgCwEGtsS1izRKVi6uFO3H
X-Received: by 2002:a5d:8198:: with SMTP id u24mr15811551ion.177.1550572384522;
        Tue, 19 Feb 2019 02:33:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550572384; cv=none;
        d=google.com; s=arc-20160816;
        b=Wvlz0Sn/B2NEoxaiJdokghveXm3/6Eg/iUjCbS/hXJH1PXpP3rdiuK6aZML9rVSS4v
         xjEhQwFINNgNxoZrQuTulFDw8hWButPRtD4Kx0kPrY5tmUf9O1YF+xVP/320TEh307Mr
         qgd2GxBxfG/KWvBX/FjJSjzX1I9iMbAcqmKYqTw7Xpw3fOpb83vlNFEe1Rj5TvBcVkBy
         8l/33Rd7/pP+HdDzYKvQMAiV+njyQWTcd+SM00Xg7ccR5Z3cLiBGMznqiXlg8LoEUsy9
         nmMRbq3ye4HmOZV36BFMI4CDekiRewwRjINENCQUchBNrWfETb3n2851iiEdPtfV1/1r
         Rnog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id:dkim-signature;
        bh=ny/EJ5kQ9AxbXrrJC6i+uZEQstUYIWoSCsf99o3ZhwQ=;
        b=gatBHwLH8Fw1xfWErXYhnY1LUPsRUDhBqJr6oKpv4LqMBF4FUDujSUXaKEfYoHrgdu
         2JJh/a5z6MhYbNn8av0emg3Dk2g6Fr8t0SkTBJ1U0GBRuZft6o76h+qhNOrz7HZCID30
         32ZUSboUmLl9DmSQShA+KhTPQmt9TjmE7QbEuOlUaUx9qTIsoLty+z32la3c1ir8z0z6
         v4cGVSIb8rUMTZ+z3wpC4DRU3MX+6SVs5Bhk//t438MWKAl2m5cndRdt1mYI3hMU3i4K
         XNGRqfxiObekHolAwq1mPuISiuEW8ZshDn8UqQ1TGp7LE3K9L7su+yH594wbPZKihoih
         8pOA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=XQc7367t;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id h12si9217969ioj.11.2019.02.19.02.33.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 02:33:04 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=XQc7367t;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Type:MIME-Version:References:
	Subject:Cc:To:From:Date:Message-Id:Sender:Reply-To:Content-Transfer-Encoding:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=ny/EJ5kQ9AxbXrrJC6i+uZEQstUYIWoSCsf99o3ZhwQ=; b=XQc7367tYJJkSbabjx+ZF1U0cv
	peTZuL3axIxoSsTGaiDBPx3VdE8jITPGn2wk16gxQa5/nu4re3CSzzrR9xqfmdu7nF4ySVJl3ABKW
	TTtBD/tTkY97Lz0dkVRS5U9atHausiyvtnJ1lp8+Zb8tg6mhcaI8sIghrCsuhfCNi9vBd+DI1J/RB
	DBbFwNeen+HZPk3OYgZ1bs5Xr7Bu9zrGYKoPrzsYMptffNKKXP0U1VK8CxEHji9o7sXQbl+4JlfUm
	qmsYGWNUy5UsX9E62bTRmiS1ieX+OPkGunA6PV1vSX6UtrG8+yF6JF4J8KjfKhthl1pzg0evDd69A
	giWBvglQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gw2hp-0000dz-9Q; Tue, 19 Feb 2019 10:32:53 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 0)
	id 80335285205A4; Tue, 19 Feb 2019 11:32:48 +0100 (CET)
Message-Id: <20190219103233.869262181@infradead.org>
User-Agent: quilt/0.65
Date: Tue, 19 Feb 2019 11:32:05 +0100
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
Subject: [PATCH v6 17/18] asm-generic/tlb: Remove tlb_flush_mmu_free()
References: <20190219103148.192029670@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

As the comment notes; it is a potentially dangerous operation. Just
use tlb_flush_mmu(), that will skip the (double) TLB invalidate if
it really isn't needed anyway.

Acked-by: Will Deacon <will.deacon@arm.com>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 include/asm-generic/tlb.h |   10 +++-------
 mm/memory.c               |    2 +-
 mm/mmu_gather.c           |    2 +-
 3 files changed, 5 insertions(+), 9 deletions(-)

--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -67,16 +67,13 @@
  *    call before __tlb_remove_page*() to set the current page-size; implies a
  *    possible tlb_flush_mmu() call.
  *
- *  - tlb_flush_mmu() / tlb_flush_mmu_tlbonly() / tlb_flush_mmu_free()
+ *  - tlb_flush_mmu() / tlb_flush_mmu_tlbonly()
  *
  *    tlb_flush_mmu_tlbonly() - does the TLB invalidate (and resets
  *                              related state, like the range)
  *
- *    tlb_flush_mmu_free() - frees the queued pages; make absolutely
- *			     sure no additional tlb_remove_page()
- *			     calls happen between _tlbonly() and this.
- *
- *    tlb_flush_mmu() - the above two calls.
+ *    tlb_flush_mmu() - in addition to the above TLB invalidate, also frees
+ *			whatever pages are still batched.
  *
  *  - mmu_gather::fullmm
  *
@@ -274,7 +271,6 @@ void arch_tlb_gather_mmu(struct mmu_gath
 void tlb_flush_mmu(struct mmu_gather *tlb);
 void arch_tlb_finish_mmu(struct mmu_gather *tlb,
 			 unsigned long start, unsigned long end, bool force);
-void tlb_flush_mmu_free(struct mmu_gather *tlb);
 
 static inline void __tlb_adjust_range(struct mmu_gather *tlb,
 				      unsigned long address,
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1155,7 +1155,7 @@ static unsigned long zap_pte_range(struc
 	 */
 	if (force_flush) {
 		force_flush = 0;
-		tlb_flush_mmu_free(tlb);
+		tlb_flush_mmu(tlb);
 		if (addr != end)
 			goto again;
 	}
--- a/mm/mmu_gather.c
+++ b/mm/mmu_gather.c
@@ -91,7 +91,7 @@ bool __tlb_remove_page_size(struct mmu_g
 
 #endif /* HAVE_MMU_GATHER_NO_GATHER */
 
-void tlb_flush_mmu_free(struct mmu_gather *tlb)
+static void tlb_flush_mmu_free(struct mmu_gather *tlb)
 {
 #ifdef CONFIG_HAVE_RCU_TABLE_FREE
 	tlb_table_flush(tlb);


