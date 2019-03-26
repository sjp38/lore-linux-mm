Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2350C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:26:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F240206DF
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:26:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F240206DF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE9D16B000A; Tue, 26 Mar 2019 12:26:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C99386B000C; Tue, 26 Mar 2019 12:26:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B60D26B0010; Tue, 26 Mar 2019 12:26:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 629146B000A
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 12:26:38 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id 41so4169908edq.0
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:26:38 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=KFvapMbUm3bXfRm+QdzupSk/zuyCEmTqI4EjOBRlsz4=;
        b=MyNFs8Yhh8EKCQMCc02yTMA54rvDz1rdaVnN8WTLd3qXQByvdSMevpbhOmhpgoXycG
         R47gObQFiNMtsj63RuY0LBDsSpUyay4XyWih7fHyOFoKcfNT60Wk9SCYcP+ucy8iZdFN
         pYEq/ZqhcDMDwVrXOKrOiLwVZiDfsZ5OsGU7vubErJgWIL+ovJ//OAQypbq3GCGtdy3W
         qGQM7DXVThWgZlhi+N1uiBp3PCchnXvbdapXbAveTnYntPWC/FRncpc407nkmvN8qO3L
         vho5PlNZFdujy0+ZAm8dpm57JUJXTCKN9QMeSnzuNZWgLbID6LtAgf/4z59pYJmcjQrm
         G2aQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAVca1DhbU0GrSsny8zB+KAa40KmRL9z/QiLmzKmlc7s58MT32Z2
	+aU3bq36Vz0afzMnK6z0+fvcZfcEihjXfJCHdfP3i5zWRR5cy9KQ0C3EmJLOf8pAfsJhn4BzHD2
	I2QTxScXNI2mj8ldzvGJRmbPI8DxS8f0O963u03HYMB9pn3xyE0k7WV1/0APbBdKSQg==
X-Received: by 2002:aa7:c64a:: with SMTP id z10mr6537992edr.84.1553617597830;
        Tue, 26 Mar 2019 09:26:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz6Euni9FvfXQqY1jUMQ6L/I/nV9i+Pib46BXpuLBeeVyo7b57qmXl9Sc02C3w+yDoYKky/
X-Received: by 2002:aa7:c64a:: with SMTP id z10mr6537932edr.84.1553617596638;
        Tue, 26 Mar 2019 09:26:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553617596; cv=none;
        d=google.com; s=arc-20160816;
        b=m3W3LuhLhQOffb5DF0CKBKIdmfaW+VBIlWPSuTkZftshhhJFrZUfMoNbjZhIb9rqaA
         CtNRsNLlP4Etfjeemb9RqfYKb8SQAngUbBkZt3f6f3enc8kHgJogdKo9BP72xmhS5sTV
         VjLT6CduZoTbbIIuy710lJxAm8UO8m2vIL79TxcheS9WpeGqBhlJyMBzgSv/7YTwoBgo
         QsIfflOKgWyKonH2KRwsX39tGUZw7X1XW6vUQ2R2uTLslwJtaqI6pYCPyY2LvRKwz0W3
         SkaE3SKRE/gereLDZID8tCw4rU3x2/y0d4/mr5Rm+4ymRFs6TFfd9ImoyVlb0V6e5A81
         YWxw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=KFvapMbUm3bXfRm+QdzupSk/zuyCEmTqI4EjOBRlsz4=;
        b=NMOTw2kuLDklP2GpzKC+2+YjqUTofgr7L2lkpm5o1F7iOMqTI3RdIr0GNEG0jwYLKQ
         of1blds9XirvwcJnPNkDGTfcTKg7e510U7blEILBKRYNwPkmd9zvoDg5oL2tq/6KWbl4
         98ON6QW8z0lRjoLcM04kAUQjVwB/Z5/KTGKcqCS984fQbQK1p4Dz7P9bIDzTJUQZ+JFg
         7zn+4FNw8rXLGsnBmSCrBoRQ5IMGw8pT13I3fmL3ZR953MxgJDvekro9Zwd3DPg729fP
         qCzPunsjI8k9nVWopD4J8g7Da16lN4r6xzoDwelGri7PyMQq4R3K2ysXLw+TCuKgRSFa
         VYeQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q3si1686351ejt.284.2019.03.26.09.26.36
        for <linux-mm@kvack.org>;
        Tue, 26 Mar 2019 09:26:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 667D01596;
	Tue, 26 Mar 2019 09:26:35 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 2A9DF3F614;
	Tue, 26 Mar 2019 09:26:32 -0700 (PDT)
From: Steven Price <steven.price@arm.com>
To: linux-mm@kvack.org
Cc: Steven Price <steven.price@arm.com>,
	Andy Lutomirski <luto@kernel.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>,
	Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ingo Molnar <mingo@redhat.com>,
	James Morse <james.morse@arm.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Will Deacon <will.deacon@arm.com>,
	x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	Mark Rutland <Mark.Rutland@arm.com>,
	"Liang, Kan" <kan.liang@linux.intel.com>
Subject: [PATCH v6 00/19] Convert x86 & arm64 to use generic page walk
Date: Tue, 26 Mar 2019 16:26:05 +0000
Message-Id: <20190326162624.20736-1-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Most architectures current have a debugfs file for dumping the kernel
page tables. Currently each architecture has to implement custom
functions for walking the page tables because the generic
walk_page_range() function is unable to walk the page tables used by the
kernel.

This series extends the capabilities of walk_page_range() so that it can
deal with the page tables of the kernel (which have no VMAs and can
contain larger huge pages than exist for user space). x86 and arm64 are
then converted to make use of walk_page_range() removing the custom page
table walkers.

To enable a generic page table walker to walk the unusual mappings of
the kernel we need to implement a set of functions which let us know
when the walker has reached the leaf entry. Since arm, powerpc, s390,
sparc and x86 all have p?d_large macros lets standardise on that and
implement those that are missing.

Potentially future changes could unify the implementations of the
debugfs walkers further, moving the common functionality into common
code. This would require a common way of handling the effective
permissions (currently implemented only for x86) along with a per-arch
way of formatting the page table information for debugfs. One
immediate benefit would be getting the KASAN speed up optimisation in
arm64 (and other arches) which is currently only implemented for x86.

Also available as a git tree:
git://linux-arm.org/linux-sp.git walk_page_range/v6

Changes since v5:
 * Updated comment for struct mm_walk based on Mike Rapoport's
   suggestion

Changes since v4:
 * Correctly force result to a boolean in p?d_large for powerpc.
 * Added Acked-bys
 * Rebased onto v5.1-rc1

Changes since v3:
 * Restored the generic macros, only implement p?d_large() for
   architectures that have support for large pages. This also means
   adding dummy #defines for architectures that define p?d_large as
   static inline to avoid picking up the generic macro.
 * Drop the 'depth' argument from pte_hole
 * Because we no longer have the depth for holes, we also drop support
   in x86 for showing missing pages in debugfs. See discussion below:
   https://lore.kernel.org/lkml/26df02dd-c54e-ea91-bdd1-0a4aad3a30ac@arm.com/
 * mips: only define p?d_large when _PAGE_HUGE is defined.

Changes since v2:
 * Rather than attemping to provide generic macros, actually implement
   p?d_large() for each architecture.

Changes since v1:
 * Added p4d_large() macro
 * Comments to explain p?d_large() macro semantics
 * Expanded comment for pte_hole() callback to explain mapping between
   depth and P?D
 * Handle folded page tables at all levels, so depth from pte_hole()
   ignores folding at any level (see real_depth() function in
   mm/pagewalk.c)

Steven Price (19):
  arc: mm: Add p?d_large() definitions
  arm64: mm: Add p?d_large() definitions
  mips: mm: Add p?d_large() definitions
  powerpc: mm: Add p?d_large() definitions
  riscv: mm: Add p?d_large() definitions
  s390: mm: Add p?d_large() definitions
  sparc: mm: Add p?d_large() definitions
  x86: mm: Add p?d_large() definitions
  mm: Add generic p?d_large() macros
  mm: pagewalk: Add p4d_entry() and pgd_entry()
  mm: pagewalk: Allow walking without vma
  mm: pagewalk: Add test_p?d callbacks
  arm64: mm: Convert mm/dump.c to use walk_page_range()
  x86: mm: Don't display pages which aren't present in debugfs
  x86: mm: Point to struct seq_file from struct pg_state
  x86: mm+efi: Convert ptdump_walk_pgd_level() to take a mm_struct
  x86: mm: Convert ptdump_walk_pgd_level_debugfs() to take an mm_struct
  x86: mm: Convert ptdump_walk_pgd_level_core() to take an mm_struct
  x86: mm: Convert dump_pagetables to use walk_page_range

 arch/arc/include/asm/pgtable.h               |   1 +
 arch/arm64/include/asm/pgtable.h             |   2 +
 arch/arm64/mm/dump.c                         | 117 +++----
 arch/mips/include/asm/pgtable-64.h           |   8 +
 arch/powerpc/include/asm/book3s/64/pgtable.h |  30 +-
 arch/powerpc/kvm/book3s_64_mmu_radix.c       |  12 +-
 arch/riscv/include/asm/pgtable-64.h          |   7 +
 arch/riscv/include/asm/pgtable.h             |   7 +
 arch/s390/include/asm/pgtable.h              |   2 +
 arch/sparc/include/asm/pgtable_64.h          |   2 +
 arch/x86/include/asm/pgtable.h               |  10 +-
 arch/x86/mm/debug_pagetables.c               |   8 +-
 arch/x86/mm/dump_pagetables.c                | 347 ++++++++++---------
 arch/x86/platform/efi/efi_32.c               |   2 +-
 arch/x86/platform/efi/efi_64.c               |   4 +-
 include/asm-generic/pgtable.h                |  19 +
 include/linux/mm.h                           |  26 +-
 mm/pagewalk.c                                |  76 +++-
 18 files changed, 407 insertions(+), 273 deletions(-)

-- 
2.20.1

