Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B7DBC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 10:33:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4BCC720818
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 10:33:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Uf4UYOw5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4BCC720818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE6198E000B; Tue, 19 Feb 2019 05:33:03 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D4C3C8E0005; Tue, 19 Feb 2019 05:33:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BC37C8E000B; Tue, 19 Feb 2019 05:33:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8C8938E0005
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 05:33:03 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id n124so3597437itb.7
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 02:33:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:user-agent:date:from
         :to:cc:subject:references:mime-version;
        bh=qaNtyiAMx95v3NfDxgkx+6ykZ729vG4R1hTpAcDIU44=;
        b=TnYmwGQXyhQZ8sZKwQL5fkrtvXGB3tlIDKz8oM5yJJ86YDqDxhhtCadn4GyOFQh9SN
         kyzffmj/qmXxYEjMHM/lBD+b7e3DKzvhD5l1DpjCEGy1NHbFPEP/qlsdPbkq9Fc7qHbG
         jAYHJ0FlERJsNbi1E/sFecLRjKLfUMOg8Lps2JWimLeDW3lOAs9xO/ipAit7P/41TIXi
         kuO4UXPc4vb8bzFB9nk2UsSP9L8GsxYeA65kgJqKmMeZyvA/KEOiIPH1OOLJtK8+HRW/
         69b1U8t/D5iZvLPmOW+GReYS3DkyyumpA1YlQqXy937KvEE9gHvrgzgxcd/NDJX+j0Qk
         EoGg==
X-Gm-Message-State: AHQUAua1JnVjM5uFQHIEI3523fisktlssaBCdTV/xeR0/4RhoVHdMSRL
	CzuB3b++LjfHbcwdZIjhCJoQpUg1V0RrutJsSXS+nyZYIC77Yx4wQ6DStl6fFubCJ/DZQrlqTWm
	MDkNn+6kOhtlYiH4RJ5uX6Naj/DExksNe0asVXuIqHXh7F3KPxiA+amFdZ85H5ko7fA==
X-Received: by 2002:a5e:8d02:: with SMTP id m2mr15542219ioj.207.1550572383335;
        Tue, 19 Feb 2019 02:33:03 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYtsWgP4/QFFbJJqO6OF2VIF/fpMKgAqy7wNllhSztOFYR55y1LcqMqOeyWpu8P7O88u9mY
X-Received: by 2002:a5e:8d02:: with SMTP id m2mr15542197ioj.207.1550572382718;
        Tue, 19 Feb 2019 02:33:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550572382; cv=none;
        d=google.com; s=arc-20160816;
        b=A3WS6hFFPPKrAwxu1gf2FypmAno5HE5Am5Thv8k0SO1P5qtnyWFR7rf0/MNmRslVnf
         yXa1kTjSs34fDEnA/YX16NbspHdAK/T31Uv8pFy7nXHz2RWy3e4dwUxu0OtpDSHwVvvE
         nEaB85x9Vpqu5Ibp504x2mSd5BNvqf2TAJuzaO7jZ470I4634xcfdRcTzNJ9wLYDq47v
         jFl36n8CpF47jIjMP+nEbBkkKIgg5um6kXUBa1d9atvmuwOGBMSniTCthl045/i80QRP
         ixz73Tm6ZSclYvTIMKSQba0VhJ6WRJ6Iy1ROhN603z6x03Wh8Nv17jiJX2oUpDv7SyBc
         S7vw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id:dkim-signature;
        bh=qaNtyiAMx95v3NfDxgkx+6ykZ729vG4R1hTpAcDIU44=;
        b=aK/5xQbhIeZK5zVfEzVK9O5IIPXyTK04ghqWxKv3maeZPxFtrZ4SDvNxKEFxxpk3fl
         Hex4f65UHVoXs1yUddb0wKFGkWrFTVNDU+rKW2H4hZtv9Zsc/VGI5FJx0a652u/FDNCV
         0jYmW7jjplmH/0T0UzJd3pLxmozQfhMO8CX/eHnsytq3fw7P6xEvI5fcl2R99OVFy9PN
         B42Pz0hiO8q+JmEA50ZKxdS8ugz5F0q5wWSd98Jyj/eKwz9+K1INDx7xE5HKUKyOBVsn
         BWWeQhz/fKsOxx8SQV74C/nN3NucgOXydxkkCbzmbUyHKGkdanuSheuhj7tgSGeCtzE0
         6aSA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=Uf4UYOw5;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id k65si340785itc.131.2019.02.19.02.33.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 02:33:02 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) client-ip=2001:8b0:10b:1231::1;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=merlin.20170209 header.b=Uf4UYOw5;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2001:8b0:10b:1231::1 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=merlin.20170209; h=Content-Type:MIME-Version:References:
	Subject:Cc:To:From:Date:Message-Id:Sender:Reply-To:Content-Transfer-Encoding:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=qaNtyiAMx95v3NfDxgkx+6ykZ729vG4R1hTpAcDIU44=; b=Uf4UYOw52uBXz0aiOBXn6K7pQe
	BngSSpPiHpvL7+dTtPpeT2Uq99VNK0928jiTMOfpeUDQc4NRQmv8LJW6OLg0mtnEJ0hO8qa/A+nFN
	eV2NiG9uciTPLcMRqPg8gEKbMQFkyaD+Y0D+9oa/BSoX7JvUcSyCanhuMm1MU346P+JbXU1Z1sNBV
	Rt+/UUTkyT162EfPqksKQvtRnS+12iKFiKwOlqHzvTMu9sII1UUVRUC3mD1b+pWSKF7+hDHcVdKhu
	fKkU+SAQ/CHEzm59Ul/czv83DD+OkhzRpgC0Fz2kkncggqwO3UXaKdJdBhLoQNQB0CCVKb5AC2pPx
	TG4P6cqQ==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by merlin.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gw2hn-0000dk-I9; Tue, 19 Feb 2019 10:32:52 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 0)
	id 5CDED285202C9; Tue, 19 Feb 2019 11:32:48 +0100 (CET)
Message-Id: <20190219103233.265497889@infradead.org>
User-Agent: quilt/0.65
Date: Tue, 19 Feb 2019 11:31:55 +0100
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
Subject: [PATCH v6 07/18] asm-generic/tlb: Invert HAVE_RCU_TABLE_INVALIDATE
References: <20190219103148.192029670@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Make issuing a TLB invalidate for page-table pages the normal case.

The reason is twofold:

 - too many invalidates is safer than too few,
 - most architectures use the linux page-tables natively
   and would thus require this.

Make it an opt-out, instead of an opt-in.

Acked-by: Will Deacon <will.deacon@arm.com>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/Kconfig              |    2 +-
 arch/arm64/Kconfig        |    1 -
 arch/powerpc/Kconfig      |    1 +
 arch/sparc/Kconfig        |    1 +
 arch/x86/Kconfig          |    1 -
 include/asm-generic/tlb.h |    9 +++++----
 mm/mmu_gather.c           |    2 +-
 7 files changed, 9 insertions(+), 8 deletions(-)

--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -372,7 +372,7 @@ config HAVE_ARCH_JUMP_LABEL_RELATIVE
 config HAVE_RCU_TABLE_FREE
 	bool
 
-config HAVE_RCU_TABLE_INVALIDATE
+config HAVE_RCU_TABLE_NO_INVALIDATE
 	bool
 
 config HAVE_MMU_GATHER_PAGE_SIZE
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -147,7 +147,6 @@ config ARM64
 	select HAVE_PERF_USER_STACK_DUMP
 	select HAVE_REGS_AND_STACK_ACCESS_API
 	select HAVE_RCU_TABLE_FREE
-	select HAVE_RCU_TABLE_INVALIDATE
 	select HAVE_RSEQ
 	select HAVE_STACKPROTECTOR
 	select HAVE_SYSCALL_TRACEPOINTS
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -218,6 +218,7 @@ config PPC
 	select HAVE_PERF_REGS
 	select HAVE_PERF_USER_STACK_DUMP
 	select HAVE_RCU_TABLE_FREE		if SMP
+	select HAVE_RCU_TABLE_NO_INVALIDATE	if HAVE_RCU_TABLE_FREE
 	select HAVE_MMU_GATHER_PAGE_SIZE
 	select HAVE_REGS_AND_STACK_ACCESS_API
 	select HAVE_RELIABLE_STACKTRACE		if PPC64 && CPU_LITTLE_ENDIAN
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -62,6 +62,7 @@ config SPARC64
 	select HAVE_KRETPROBES
 	select HAVE_KPROBES
 	select HAVE_RCU_TABLE_FREE if SMP
+	select HAVE_RCU_TABLE_NO_INVALIDATE if HAVE_RCU_TABLE_FREE
 	select HAVE_MEMBLOCK_NODE_MAP
 	select HAVE_ARCH_TRANSPARENT_HUGEPAGE
 	select HAVE_DYNAMIC_FTRACE
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -183,7 +183,6 @@ config X86
 	select HAVE_PERF_REGS
 	select HAVE_PERF_USER_STACK_DUMP
 	select HAVE_RCU_TABLE_FREE		if PARAVIRT
-	select HAVE_RCU_TABLE_INVALIDATE	if HAVE_RCU_TABLE_FREE
 	select HAVE_REGS_AND_STACK_ACCESS_API
 	select HAVE_RELIABLE_STACKTRACE		if X86_64 && (UNWINDER_FRAME_POINTER || UNWINDER_ORC) && STACK_VALIDATION
 	select HAVE_FUNCTION_ARG_ACCESS_API
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -135,11 +135,12 @@
  *  When used, an architecture is expected to provide __tlb_remove_table()
  *  which does the actual freeing of these pages.
  *
- *  HAVE_RCU_TABLE_INVALIDATE
+ *  HAVE_RCU_TABLE_NO_INVALIDATE
  *
- *  This makes HAVE_RCU_TABLE_FREE call tlb_flush_mmu_tlbonly() before freeing
- *  the page-table pages. Required if you use HAVE_RCU_TABLE_FREE and your
- *  architecture uses the Linux page-tables natively.
+ *  This makes HAVE_RCU_TABLE_FREE avoid calling tlb_flush_mmu_tlbonly() before
+ *  freeing the page-table pages. This can be avoided if you use
+ *  HAVE_RCU_TABLE_FREE and your architecture does _NOT_ use the Linux
+ *  page-tables natively.
  *
  *  MMU_GATHER_NO_RANGE
  *
--- a/mm/mmu_gather.c
+++ b/mm/mmu_gather.c
@@ -157,7 +157,7 @@ bool __tlb_remove_page_size(struct mmu_g
  */
 static inline void tlb_table_invalidate(struct mmu_gather *tlb)
 {
-#ifdef CONFIG_HAVE_RCU_TABLE_INVALIDATE
+#ifndef CONFIG_HAVE_RCU_TABLE_NO_INVALIDATE
 	/*
 	 * Invalidate page-table caches used by hardware walkers. Then we still
 	 * need to RCU-sched wait while freeing the pages because software


