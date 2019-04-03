Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74660C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:17:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F5D220830
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:17:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F5D220830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C2AD36B0008; Wed,  3 Apr 2019 10:17:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BDCEC6B000A; Wed,  3 Apr 2019 10:17:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA0366B000C; Wed,  3 Apr 2019 10:17:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5A8B76B0008
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 10:17:15 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id m32so7695258edd.9
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 07:17:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=aUZA5yJkkPHKogGfUp3CTzkSHn4dJ6fAKWbxMiOkkQA=;
        b=glFHRlrI7urXhD/PP3focjYXhK0MDmv8ZpANDctGQFweRcq7YiSLuLYTD+AuH76JWY
         M9iwiw5qVUREsSVJYSVsFJCpnih+1kyBFmhyVURxD/PAo8qS6q40tLfCkzdeLKC4QShG
         rzenTvHcwPI9L454F+XaMS31j11ska64QPz6pyRDDAQ4Ec7fpAVnaoqt9XoJAV05BGkM
         K3RjkM0by1CGRcvCxdf4q2PBQSL60KndXbcwNK5jPgJYMmyquC3fkIVGXXEQiAfhQlwk
         Q1543llMH/nK4G+gGTyWhoVClNIgDUx21DWzUZ7u2MqhsBCAUSKEPlDFIjQ2j7TkXd6J
         la6Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAUt3Va1cfpH9p21RBBz1cPwSbRn8KFBAtq94Rbw+FnuUFPCoabg
	ZkM7mGtII3NQQY7RZNhU9rjZYa7/+48wVMLGJNh6RLBdyAyERjpX57UjNpv9B+YcOANfLou0UWk
	B9TBzV5TbYHYoYbAvHf1mLHXdMOVnS+v0PwGAHzcdHtK5XZdNenP3kTUy/cjrFvLB0w==
X-Received: by 2002:a17:906:49d9:: with SMTP id w25mr18674ejv.52.1554301034836;
        Wed, 03 Apr 2019 07:17:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwVv1Uky86FXaPQQyEqN82ziB0DjpNCtKu65GR9xLGM6+Ma/nvXMfWLERtin03k7j8uvz4z
X-Received: by 2002:a17:906:49d9:: with SMTP id w25mr18586ejv.52.1554301032915;
        Wed, 03 Apr 2019 07:17:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554301032; cv=none;
        d=google.com; s=arc-20160816;
        b=t5WV7tp9MzUxqFdWfgts3MZfio79aQlJr4T9j6RLIohJA6fxEQ0qqGUi3h8GR5r9ym
         UqRhazxf/CBrJJGidYkOHIcXaBDPgAdI/lYtPIDm0xufdTENTbtf84ve/pleApQYGr5w
         OLVSmrTd3G2od1rjMO0w7A4jcq1FohIFb0uwuhfD3n9KSgn9OQhfJ7C1j9i3QJqCtPWm
         6795RKwcEvxVbzhu84p8iLa/lJzQQnkSx3C5+eUIOy3UvbX8CuU3NMJiWV6k9jmIZBYg
         EAk3LHmw27TulfqjGt20zj/LYh/Nfbk2bgoHAMj6UmyeByIQwjM1Uza7A8du2w2e+OqX
         3b3Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=aUZA5yJkkPHKogGfUp3CTzkSHn4dJ6fAKWbxMiOkkQA=;
        b=R6MzsupEQfygJ0P/D+p9N8yt76oQk2z2FYI5bfvCQue8jK+S06XvG+qDrPml+Q8kc6
         1EoTIandSmvzw1yUIXIn0wLtujg3IhDjpFWWsUs01/27lVl3Y2jQJbdtQmWXDR0WkXL+
         Op8DJP3Xyd/i2+jpFpYP+Ebvtr5knt3fqipwFMKdpy0ZFC1l7ZKavqlfDw8EQBbS8qcP
         BS/nj+XvjRywc7Yc8Hy3pAMN3euCmI5ZUnXtc+qOIhS1LE5ll7B/FVElKioOsf25GJjY
         bWTKSDTlzQk8a21RNf2frvvoJ53tz0cAPsZNF85ouG8uDqWWY7i93y2y/o7Ahwaj8X8j
         g3Yg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id n17si2953925edr.198.2019.04.03.07.17.12
        for <linux-mm@kvack.org>;
        Wed, 03 Apr 2019 07:17:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 7FEAEA78;
	Wed,  3 Apr 2019 07:17:11 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 1D29D3F68F;
	Wed,  3 Apr 2019 07:17:07 -0700 (PDT)
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
	"Liang, Kan" <kan.liang@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH v8 00/20] Convert x86 & arm64 to use generic page walk
Date: Wed,  3 Apr 2019 15:16:07 +0100
Message-Id: <20190403141627.11664-1-steven.price@arm.com>
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
git://linux-arm.org/linux-sp.git walk_page_range/v8

Changes since v7:
https://lore.kernel.org/lkml/20190328152104.23106-1-steven.price@arm.com/T/
 * Updated commit message in patch 2 to clarify that we rely on the page
   tables being walked to be the same page size/depth as the kernel's
   (since this confused me earlier today).

Changes since v6:
https://lore.kernel.org/lkml/20190326162624.20736-1-steven.price@arm.com/T/
 * Split the changes for powerpc. pmd_large() is now added in patch 4
   patch, and pmd_is_leaf() removed in patch 5.

Changes since v5:
https://lore.kernel.org/lkml/20190321141953.31960-1-steven.price@arm.com/T/
 * Updated comment for struct mm_walk based on Mike Rapoport's
   suggestion

Changes since v4:
https://lore.kernel.org/lkml/20190306155031.4291-1-steven.price@arm.com/T/
 * Correctly force result to a boolean in p?d_large for powerpc.
 * Added Acked-bys
 * Rebased onto v5.1-rc1

Changes since v3:
https://lore.kernel.org/lkml/20190227170608.27963-1-steven.price@arm.com/T/
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
https://lore.kernel.org/lkml/20190221113502.54153-1-steven.price@arm.com/T/
 * Rather than attemping to provide generic macros, actually implement
   p?d_large() for each architecture.

Changes since v1:
https://lore.kernel.org/lkml/20190215170235.23360-1-steven.price@arm.com/T/
 * Added p4d_large() macro
 * Comments to explain p?d_large() macro semantics
 * Expanded comment for pte_hole() callback to explain mapping between
   depth and P?D
 * Handle folded page tables at all levels, so depth from pte_hole()
   ignores folding at any level (see real_depth() function in
   mm/pagewalk.c)

Steven Price (20):
  arc: mm: Add p?d_large() definitions
  arm64: mm: Add p?d_large() definitions
  mips: mm: Add p?d_large() definitions
  powerpc: mm: Add p?d_large() definitions
  KVM: PPC: Book3S HV: Remove pmd_is_leaf()
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

