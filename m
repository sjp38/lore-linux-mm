Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B6519C0650F
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:57:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 710132089E
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:57:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 710132089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 047878E0013; Tue, 30 Jul 2019 01:57:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F12738E0003; Tue, 30 Jul 2019 01:56:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DB37D8E0013; Tue, 30 Jul 2019 01:56:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8AA8B8E0003
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 01:56:59 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id i9so39613559edr.13
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 22:56:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=cBxJ1KxcGmfDIECI8Cra5LnZouD+2DUEmB1lShztgnM=;
        b=DEbh9anIjIBa3SM5QagnivogVJsbdz+/v4vrjooOCmjN2CPnBTBs4YxCtCRmiCQMjC
         rDJj7whKqHtSKdWBMB4EY3vvNugTSh7hql/f8U3mg22l+I5MuV36HvvhHFqm3rj8nKSw
         3owwHOELewRijOIcXtOl+gp0EiGfRDW4LXCMJheWx6WYKmvA5lHQRFOfMPqZ3hScP/9y
         ZYeDFYRv6zJYw+Sm1NwI8zgWcIFe3/nzbyMWsrHNYhNIHrOG+4omEapMycJnD1SxSaEa
         Hy/zfLQsVazv6DQyCUddA3zHo0N2jT3+T3lOIIofV5KtCZbktWpgSUDHtHA35aJm4Kmm
         04Yw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAV3sb/WupfmcUtU7nzh67FyGKPmkCIaUh86m5u+srZT3C+lsDSS
	uOhFSIruZjztaPGGGwnJf5clPHZqA3ijxTBXtOJuwvC0G/Vux9DFea4KBDKSOWHDNAT5M4cs468
	KsU2L0mtJLpsLD1S9FP5QBaCS1ASO+zRFv1/pmO5jkcRT8ZN0ivB/+Ppwml5o4SQ=
X-Received: by 2002:a17:906:f198:: with SMTP id gs24mr86303456ejb.6.1564466219035;
        Mon, 29 Jul 2019 22:56:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy8K9jMG0Yyt59DpVWg9X9O6Y12/0bPUwv/1veiu2UT+SCyiNGpOLFQ3g0UDZ6R31KoJYeR
X-Received: by 2002:a17:906:f198:: with SMTP id gs24mr86303419ejb.6.1564466218152;
        Mon, 29 Jul 2019 22:56:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564466218; cv=none;
        d=google.com; s=arc-20160816;
        b=aabw7XJ91rj0HB3lEq3Bh2rd+g4HmlRcv0XBUMIXZUVs4DSoFJgKCq51jqI6ZEig6L
         UHDjNU/yl+KtTpXkhf0yDR/Afn6mHXVPStP+ybvptL8M8mNl9ZrKj0spKOEMP39yweSV
         xcq/AYyZmEXrUWYlPg6JgXbAp89ynyAoVOClCYyunpX56Qbp00NwSRXuYZtXbxX4mUHV
         ZesEdpwkOOExiOfboMg053pgF2QpJSlwaVs/JyZIkAH9HpgtyU/u1Lq8Db55kUwgbW67
         U/pXeNMvWGTw3rO8nzTU9W6FIKTFQ4VuJvQhwQdZhvexQoqRh6hydCZfrXyY/2JQaBxj
         ZdNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=cBxJ1KxcGmfDIECI8Cra5LnZouD+2DUEmB1lShztgnM=;
        b=exCZtUF10RoIceIfkc2BKkO4YM4eKRFNzYC7mq2wJvX7mUEnN+lvp/CyeEohEH+jEs
         HZvY07phKg8opz/mQkx4QAeZ/duO4yy6X/o/oNBkDeo4vr0vTJnnnyalanzPaj0Iaf3E
         AR4shjdvfj7mrf/QljN9AuOmKI6jqRJ1bMYOpEYYoNo/v+yboHZTpyUU9gcBgVZGo0Gv
         r5axdtBAdrlS4wS+VIVOOs1MD2nNQBcD2fDGfYQrKBEgTFaN7v7xWFxYzwsoL9PmUfyv
         Wgj1PoBCTMGRxfmp5+47+kWyWSXv95Oyu1HRU2fqR5fGm0u1/IMpq1ctw4Fk42rjRKGC
         LYww==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay1-d.mail.gandi.net (relay1-d.mail.gandi.net. [217.70.183.193])
        by mx.google.com with ESMTPS id j9si17327867edn.191.2019.07.29.22.56.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 29 Jul 2019 22:56:58 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.193;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.193 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay1-d.mail.gandi.net (Postfix) with ESMTPSA id ED0F7240009;
	Tue, 30 Jul 2019 05:56:51 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Luis Chamberlain <mcgrof@kernel.org>,
	Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Kees Cook <keescook@chromium.org>,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v5 05/14] arm64, mm: Make randomization selected by generic topdown mmap layout
Date: Tue, 30 Jul 2019 01:51:04 -0400
Message-Id: <20190730055113.23635-6-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190730055113.23635-1-alex@ghiti.fr>
References: <20190730055113.23635-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This commits selects ARCH_HAS_ELF_RANDOMIZE when an arch uses the generic
topdown mmap layout functions so that this security feature is on by
default.
Note that this commit also removes the possibility for arm64 to have elf
randomization and no MMU: without MMU, the security added by randomization
is worth nothing.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Acked-by: Catalin Marinas <catalin.marinas@arm.com>
Acked-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Luis Chamberlain <mcgrof@kernel.org>
---
 arch/Kconfig                |  1 +
 arch/arm64/Kconfig          |  1 -
 arch/arm64/kernel/process.c |  8 --------
 mm/util.c                   | 11 +++++++++--
 4 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index a0bb6fa4d381..d4c1f0551dfe 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -705,6 +705,7 @@ config HAVE_ARCH_COMPAT_MMAP_BASES
 config ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT
 	bool
 	depends on MMU
+	select ARCH_HAS_ELF_RANDOMIZE
 
 config HAVE_COPY_THREAD_TLS
 	bool
diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 14a194e63458..399f595ef852 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -16,7 +16,6 @@ config ARM64
 	select ARCH_HAS_DMA_MMAP_PGPROT
 	select ARCH_HAS_DMA_PREP_COHERENT
 	select ARCH_HAS_ACPI_TABLE_UPGRADE if ACPI
-	select ARCH_HAS_ELF_RANDOMIZE
 	select ARCH_HAS_FAST_MULTIPLIER
 	select ARCH_HAS_FORTIFY_SOURCE
 	select ARCH_HAS_GCOV_PROFILE_ALL
diff --git a/arch/arm64/kernel/process.c b/arch/arm64/kernel/process.c
index f674f28df663..8ddc2471b054 100644
--- a/arch/arm64/kernel/process.c
+++ b/arch/arm64/kernel/process.c
@@ -548,14 +548,6 @@ unsigned long arch_align_stack(unsigned long sp)
 	return sp & ~0xf;
 }
 
-unsigned long arch_randomize_brk(struct mm_struct *mm)
-{
-	if (is_compat_task())
-		return randomize_page(mm->brk, SZ_32M);
-	else
-		return randomize_page(mm->brk, SZ_1G);
-}
-
 /*
  * Called from setup_new_exec() after (COMPAT_)SET_PERSONALITY.
  */
diff --git a/mm/util.c b/mm/util.c
index 0781e5575cb3..16f1e56e2996 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -321,7 +321,15 @@ unsigned long randomize_stack_top(unsigned long stack_top)
 }
 
 #ifdef CONFIG_ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT
-#ifdef CONFIG_ARCH_HAS_ELF_RANDOMIZE
+unsigned long arch_randomize_brk(struct mm_struct *mm)
+{
+	/* Is the current task 32bit ? */
+	if (!IS_ENABLED(CONFIG_64BIT) || is_compat_task())
+		return randomize_page(mm->brk, SZ_32M);
+
+	return randomize_page(mm->brk, SZ_1G);
+}
+
 unsigned long arch_mmap_rnd(void)
 {
 	unsigned long rnd;
@@ -335,7 +343,6 @@ unsigned long arch_mmap_rnd(void)
 
 	return rnd << PAGE_SHIFT;
 }
-#endif /* CONFIG_ARCH_HAS_ELF_RANDOMIZE */
 
 static int mmap_is_legacy(struct rlimit *rlim_stack)
 {
-- 
2.20.1

