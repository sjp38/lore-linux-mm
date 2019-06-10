Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D2E6C4321B
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:16:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B25A82082E
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 22:16:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="g7MV9hKQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B25A82082E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5DEA16B0271; Mon, 10 Jun 2019 18:16:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 569326B0272; Mon, 10 Jun 2019 18:16:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3BB3F6B0273; Mon, 10 Jun 2019 18:16:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id EFAC76B0271
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 18:16:42 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 30so7746749pgk.16
        for <linux-mm@kvack.org>; Mon, 10 Jun 2019 15:16:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=lVE4VBqJB+KkG+FIxfoQqL75aQVlp7EZak10nik7k0k=;
        b=cHWLbmPXxCoQoYcRC9GoIh0LAKNaYat/ZbyMeIgvbPloLFFvbTdLSHFzvj0XWSV8zn
         QM/M17TwRZ9csyaZaHZgzOw2jb1mOVR/WBoBi1pHWRb4MujOheQJQRLhhmfLS0sMFdJh
         zkoroJvzsGtWAceWXWcVFqbLaJfzf4AQ1pdt3NpphVCGbA767H+9tCdiNeK5hUR+k0ze
         mr0q6zENW1p50AvKPkCp6XX16VFgTev3wz06LDl8yXX1D6j0nmyptvt/Y6GQh7NdP1y2
         nLin2CIBli+09o9QY9dn8oWIQWqiiRIjj3QiTvdgUy1X4+KKcUtrjNasixAtCSDfskk0
         Bjig==
X-Gm-Message-State: APjAAAUnWu5b3koFy4l7jOdV2B8jkCesiJhjbbRbxNLrA2CWgWcsKU6f
	qs5idyS4EjYTc7FnQH7PJV3DhlCnLfprn59l7hP9zANk/yIUP+RG74ON+9icIjD3jKDh2Mv04Ld
	oR+oizb5PO8ZIjlC2TICzey3xo2VEwkoIW3SkAtEOJhuxWEifRcEeXh7zUATni/g=
X-Received: by 2002:aa7:8e19:: with SMTP id c25mr41419570pfr.238.1560205002639;
        Mon, 10 Jun 2019 15:16:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwogLp6VhV+1AVBWU2jua0got4zWo8SCDQn/RlEsESmpIDosCxtUufUSZah0dN4rR40myib
X-Received: by 2002:aa7:8e19:: with SMTP id c25mr41419492pfr.238.1560205001706;
        Mon, 10 Jun 2019 15:16:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560205001; cv=none;
        d=google.com; s=arc-20160816;
        b=Hj7qQDpoOGVYbxX6BVseC1zR5qrjOit85ACNtC03fiBfj/ttYXOeSZwSPt0CQh30jV
         EW4moVliALaKa/tZMN13daUngvw4fhcb7k547ONfmxs70hDmwJGMuXpJF16Y+BIk6c5Z
         7IYHDKvOfcVP0e6tGng3+Sw9kw4L6/2Ornga/s88Cb3TwgqLer0QuGI4Brx2KYAjH3wR
         A4v9RbDNXiUoUIDxzWYJ3YeRQqN4AEotLyDXe7n463FY+IgQlJbIPDKAlzGewTMCRw0Y
         vljzwysxhxCRRl0CNj3qnAB/LXybp3uZVn+gB8XA1REKEnaUPcWLJQ9RUvv7l93PAxim
         gMWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=lVE4VBqJB+KkG+FIxfoQqL75aQVlp7EZak10nik7k0k=;
        b=qc57ruFwE7oU244mR90WcKMaRMOXTmTbU28BVUdukVoYqfdWLS45ctff0pdNsYT2Dr
         DA7GLysS1xZJBOpa2kQujCOc8X0t3pXnZHGFeVtGYqRmfS9zqrg85uIyMw+8/LhoO76e
         hjdJTDyLS1VuZ55lOxsG3X45x4RX6VFEXwpYjNX/RO9Zo+3PNCaRuY7sii7RkZCfHMlC
         2hC6FvFQm43JCgLAUCaAGNphpJxr7wrekcwypRV08YPboukvBrul7JXu3Gy+fxCO4+Tq
         kh/eSV2Lp3y0Uw8a3Jwz4J/Y8xxPGyMj47FId9IVORuhF7IHIIax6vHikn9RY2wvKWLW
         f+kw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=g7MV9hKQ;
       spf=pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 97si11234398ple.161.2019.06.10.15.16.41
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 10 Jun 2019 15:16:41 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=g7MV9hKQ;
       spf=pass (google.com: best guess record for domain of batv+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+ba9daad91d8a220a3b0a+5769+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=lVE4VBqJB+KkG+FIxfoQqL75aQVlp7EZak10nik7k0k=; b=g7MV9hKQoNw5gI26t9jxExxpCz
	y+RoLH7nrhvOd0+tEwTwrMivkxztKInbGwugrmpiQFPeopqZoRhBHypBsX+F4rKxzss1ujMWclj2L
	V2ZngcPWW3tXn6sAIx1eV9VUPJfqbjvq8WK5ebICyPboFn5qZ3m95ENz1v70yAAt0F7E7bVo+1Yjv
	skAqfYXdAeo1RmOxNKqt2FyihTKFOXZubw9xhxq4COqdDGAHX/b2C0oRMvH5jv+ou/cPV7+SlC1LO
	lWDSUEv7+HmoZ2qD0Ji4RSL9S7vB/ZQg8bfcFXHneu7AvuwKzA4kPDZl+wsCwWQo8U0e+HsYnUBhM
	3wbqTVdQ==;
Received: from 089144193064.atnat0002.highway.a1.net ([89.144.193.64] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1haSal-000319-AM; Mon, 10 Jun 2019 22:16:39 +0000
From: Christoph Hellwig <hch@lst.de>
To: Palmer Dabbelt <palmer@sifive.com>
Cc: Damien Le Moal <damien.lemoal@wdc.com>,
	linux-riscv@lists.infradead.org,
	uclinux-dev@uclinux.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 06/17] riscv: clear the instruction cache and all registers when booting
Date: Tue, 11 Jun 2019 00:16:10 +0200
Message-Id: <20190610221621.10938-7-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190610221621.10938-1-hch@lst.de>
References: <20190610221621.10938-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

When we get booted we want a clear slate without any leaks from previous
supervisors or the firmware.  Flush the instruction cache and then clear
all registers to known good values.  This is really important for the
upcoming nommu support that runs on M-mode, but can't really harm when
running in S-mode either.  Vaguely based on the concepts from opensbi.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/riscv/kernel/head.S | 83 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 83 insertions(+)

diff --git a/arch/riscv/kernel/head.S b/arch/riscv/kernel/head.S
index 4e46f31072da..5681179183d4 100644
--- a/arch/riscv/kernel/head.S
+++ b/arch/riscv/kernel/head.S
@@ -11,6 +11,7 @@
 #include <asm/thread_info.h>
 #include <asm/page.h>
 #include <asm/csr.h>
+#include <asm/hwcap.h>
 
 __INIT
 ENTRY(_start)
@@ -18,6 +19,12 @@ ENTRY(_start)
 	csrw CSR_SIE, zero
 	csrw CSR_SIP, zero
 
+	/* flush the instruction cache */
+	fence.i
+
+	/* Reset all registers except ra, a0,a1 */
+	call reset_regs
+
 	/* Load the global pointer */
 .option push
 .option norelax
@@ -160,6 +167,82 @@ relocate:
 	j .Lsecondary_park
 END(_start)
 
+ENTRY(reset_regs)
+	li	sp, 0
+	li	gp, 0
+	li	tp, 0
+	li	t0, 0
+	li	t1, 0
+	li	t2, 0
+	li	s0, 0
+	li	s1, 0
+	li	a2, 0
+	li	a3, 0
+	li	a4, 0
+	li	a5, 0
+	li	a6, 0
+	li	a7, 0
+	li	s2, 0
+	li	s3, 0
+	li	s4, 0
+	li	s5, 0
+	li	s6, 0
+	li	s7, 0
+	li	s8, 0
+	li	s9, 0
+	li	s10, 0
+	li	s11, 0
+	li	t3, 0
+	li	t4, 0
+	li	t5, 0
+	li	t6, 0
+	csrw	sscratch, 0
+
+#ifdef CONFIG_FPU
+	csrr	t0, misa
+	andi	t0, t0, (COMPAT_HWCAP_ISA_F | COMPAT_HWCAP_ISA_D)
+	bnez	t0, .Lreset_regs_done
+
+	li	t1, SR_FS
+	csrs	sstatus, t1
+	fmv.s.x	f0, zero
+	fmv.s.x	f1, zero
+	fmv.s.x	f2, zero
+	fmv.s.x	f3, zero
+	fmv.s.x	f4, zero
+	fmv.s.x	f5, zero
+	fmv.s.x	f6, zero
+	fmv.s.x	f7, zero
+	fmv.s.x	f8, zero
+	fmv.s.x	f9, zero
+	fmv.s.x	f10, zero
+	fmv.s.x	f11, zero
+	fmv.s.x	f12, zero
+	fmv.s.x	f13, zero
+	fmv.s.x	f14, zero
+	fmv.s.x	f15, zero
+	fmv.s.x	f16, zero
+	fmv.s.x	f17, zero
+	fmv.s.x	f18, zero
+	fmv.s.x	f19, zero
+	fmv.s.x	f20, zero
+	fmv.s.x	f21, zero
+	fmv.s.x	f22, zero
+	fmv.s.x	f23, zero
+	fmv.s.x	f24, zero
+	fmv.s.x	f25, zero
+	fmv.s.x	f26, zero
+	fmv.s.x	f27, zero
+	fmv.s.x	f28, zero
+	fmv.s.x	f29, zero
+	fmv.s.x	f30, zero
+	fmv.s.x	f31, zero
+	csrw	fcsr, 0
+#endif /* CONFIG_FPU */
+.Lreset_regs_done:
+	ret
+END(reset_regs)
+
 __PAGE_ALIGNED_BSS
 	/* Empty zero page */
 	.balign PAGE_SIZE
-- 
2.20.1

