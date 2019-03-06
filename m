Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FEC9C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:50:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2A6D220663
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:50:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A6D220663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CAF3F8E0004; Wed,  6 Mar 2019 10:50:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C5E648E0002; Wed,  6 Mar 2019 10:50:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B4D298E0004; Wed,  6 Mar 2019 10:50:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5FDC98E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 10:50:49 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id i20so6544359edv.21
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 07:50:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=/mEMh2r/giq9s4XzT8uZHvOLMUtKJN2FJqE3zao563s=;
        b=ijlYbVlZ0YDUuzx0bAX5yMwj2KDZzwrlkBVvGpboVfvngBjLEBd5Ck8KmG1tB5Tm81
         UrD+1TU56IdlUoxhS7589KNObd1YAcZLq6UJB6vSOB3od1z8lHU1ID20L/wukKPvUhLw
         W9FwiSRMB3SZuYGhw9qCjoYeYodaoCnvTx8Tk66xKzQggABGLTRIdYvHHc2u6sk55rrh
         fuTj6lUjHuDUTxAzn8cqyZhfv6mKhbrYDZ58GJKGVkrHKdo5VsnyJIq1yQYMqoL++sSC
         88o980Tj6VEtpKl3P9XaCauRY8ix6A5Q/aqTo/XCyU5lRBCIprH8UmrYmJokFgv+rruu
         Jw9g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAV3Sz6SVwNtIzRYYHsuE55vFqI7tQsIP4Z1Uo09+/C/7iq3K5E8
	fMm/5cqar+4qw8R+SMJg23yDa8BnYHjAf+qY2MygdoX26a/BvqhSV1X+D692SXHO8f8xDNsMFYd
	fMdqPKLaIviiHlACvTlBvDN1c73MbjJKBuynPiznKn95fcUiNYT/BU6jFKu5yO3qubw==
X-Received: by 2002:a50:f5b8:: with SMTP id u53mr24098694edm.204.1551887448577;
        Wed, 06 Mar 2019 07:50:48 -0800 (PST)
X-Google-Smtp-Source: APXvYqxUNhvCk9717FNrggEslaI3TwLv2puJK8mQyz6O0GXRn2rqwgHk7/WLVVk96d7QyALWX0xS
X-Received: by 2002:a50:f5b8:: with SMTP id u53mr24098567edm.204.1551887446950;
        Wed, 06 Mar 2019 07:50:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551887446; cv=none;
        d=google.com; s=arc-20160816;
        b=YJSTAsKq0Y06cFfVbAwmotq0RWkR/vIC6O/lfXHXVqiYUzWLVZoeGHvtrDgYjRu0BY
         1FvWpHOmJdvz5wWE74GOcz+UTQbd25Iuu7F/fGG7rcPRzZsvMmZDd26fnXMUZAX9RSsd
         dFHYDeXw82pNjd+vmGERLyWRWlkXFAp207MKD1OdQOHyIi64T4iDkGgpEtkP6RSt5jPp
         5wgMx45yqVKP41eU1ClTHo+YE7rnLMA13Hu/uSswgPYLlmkGSPXhkRhlnZ4b04fR/8Sn
         Vlo4Xud2wxJZ65nonComTuT8VEbCCjTCKBrB4pLbR420r/HU6z+uuTFAOJ3J6e9ULmgg
         KWpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=/mEMh2r/giq9s4XzT8uZHvOLMUtKJN2FJqE3zao563s=;
        b=p0sstDXyS/36I1t14xBW6XY8/lEatdF536gd9KhUXAyCI85mluQOTcxPEEc4ujLeEB
         ArpO5zxVdg96hx0fR+Kso4fY1indWIbW7TvhwEXnGz+fh9SyUOik2JSqfzuKO5JIVZyo
         iogYDa7929O5PXBxvWr5vIou8R+b6vBV/z+SuDVBkNI6MT07yG+QP4tvrQUb1AFP5wJW
         RBiFhxPXcB+FjutWS5kTTrzUXv0pbTHycc3dIiwnUpiffHG5mszN5bRIJZzLkvjyPaeh
         vQzZJtNGHfNrv7eecsqhGDOMst+IGP8VbSoYcxSEyW6hkt4Ho8PX+4ZtElkpFlxbgfVq
         fLmA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id x28si753961edd.234.2019.03.06.07.50.46
        for <linux-mm@kvack.org>;
        Wed, 06 Mar 2019 07:50:46 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C31F180D;
	Wed,  6 Mar 2019 07:50:45 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 870023F703;
	Wed,  6 Mar 2019 07:50:42 -0800 (PST)
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
Subject: [PATCH v4 00/19] Convert x86 & arm64 to use generic page walk
Date: Wed,  6 Mar 2019 15:50:12 +0000
Message-Id: <20190306155031.4291-1-steven.price@arm.com>
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
 arch/arm64/mm/dump.c                         | 117 ++++---
 arch/mips/include/asm/pgtable-64.h           |   8 +
 arch/powerpc/include/asm/book3s/64/pgtable.h |  30 +-
 arch/powerpc/kvm/book3s_64_mmu_radix.c       |  12 +-
 arch/riscv/include/asm/pgtable-64.h          |   7 +
 arch/riscv/include/asm/pgtable.h             |   7 +
 arch/s390/include/asm/pgtable.h              |   2 +
 arch/sparc/include/asm/pgtable_64.h          |   2 +
 arch/x86/include/asm/pgtable.h               |  10 +-
 arch/x86/mm/debug_pagetables.c               |   8 +-
 arch/x86/mm/dump_pagetables.c                | 349 ++++++++++---------
 arch/x86/platform/efi/efi_32.c               |   2 +-
 arch/x86/platform/efi/efi_64.c               |   4 +-
 include/asm-generic/pgtable.h                |  19 +
 include/linux/mm.h                           |  20 +-
 mm/pagewalk.c                                |  76 +++-
 18 files changed, 404 insertions(+), 272 deletions(-)

-- 
2.20.1

