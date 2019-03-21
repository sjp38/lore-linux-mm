Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0D09C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 14:20:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 77D08218E2
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 14:20:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 77D08218E2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A2616B0006; Thu, 21 Mar 2019 10:20:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 250646B0007; Thu, 21 Mar 2019 10:20:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1405A6B000C; Thu, 21 Mar 2019 10:20:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id B32B06B0006
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 10:20:08 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id o9so2274887edh.10
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 07:20:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=G4SFEz/3AaqQEEXj8cs47qCUdtwHQyhlXN8tBHFlLmc=;
        b=elVQA9ZBqN8DYvZj8xY4F1/fMgMYtC4vmejLZNOCR6txIexO48Md2q+0KtQiKloxFD
         nAdm1/EKm2RptnvtXN+8wGGEeKdV+fBBuTmogMUzqruV0Gf9eFuIkkZJha/ElRm2/MCO
         oNEMN2ZmLma9M5nAOcYHrkWdoYybwF+ci+0agAUXFqcSdaZyLETp1K56VhqWiA3WRipn
         y1m40Ho9YwZcLf2ZpTt4JgDIJ6w3S5UwmPA5JPiIW4u3U6HW6/uwvLhzuAMWAqbu8AZq
         DPbBlkHx7ObG3KVtLbWWBnzkYpaO94UsR3GiqI7z2Waa3XLSnLPbsHXaKZ8uoo8BEBgE
         5N/A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAXamBt9oTGeTVkYPgqXGCFNcnB2qJxb5K80cHj9HioW6FwdIHiQ
	yh4gK+3ysBcrTCusUTTMGj+BnK6ktlZQ4o3jkR9qkVf+lR+2LoZjE7kA2fb7kH1E335+WegM3SS
	ZjP2BA3D3VdzSe68ofAcx//7Il1tmB5rEfpgXp9hNoJBEHPTDYQTe60lPi9cA+SdWdg==
X-Received: by 2002:a50:ca81:: with SMTP id x1mr2548588edh.106.1553178008233;
        Thu, 21 Mar 2019 07:20:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwWVh3lE2od4+D/gTWDrp64e5CvvYcBOw1EJyqOt5dla8vgi9j1mlp01fPxeyi+dLBJLIXh
X-Received: by 2002:a50:ca81:: with SMTP id x1mr2548537edh.106.1553178007257;
        Thu, 21 Mar 2019 07:20:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553178007; cv=none;
        d=google.com; s=arc-20160816;
        b=KnHfOfBdVO31tgAjBo6CoxL5XE2vhxK1wVoYXOeOMNMYe8KscD1iGIDUlHYlglZODl
         7yn+ez0/1DauZeIhY+7eBFwoC/y9dk17X0mCBg7UJvu8YlmSPHHgvu+imDxKIN5E22PQ
         xMWqlyFveJeHySrCnP2gaNEv+jxXAMXG7edkR4p3YrctbTp8vx58Qpw6NvgmiAb7rJSo
         SLHJmjXpEEP7BAPXwkHqMoqCpob8UmsOUEHMx9P8RiiiC6xhgZhbQXkzr2n5z10qUdu/
         FlqlZj0Rashrdp765XFseUAG/lsHwhg/Ft70kV5nB0k0Au/cGssoT0XtloRbCMIeBhMc
         GCgg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=G4SFEz/3AaqQEEXj8cs47qCUdtwHQyhlXN8tBHFlLmc=;
        b=gCgUx7iIiOyFA0v3l998aaG9Dzyg7gqwlVsvcJ4eL7FvIgeOyjDqdVj3Xi/lKRakIG
         KP8FLqkKPKycXODsrNtXtWvgTTyT8zJn4YzrI4pC7FROOI78ORDyTiSDQOH5vLOYARN3
         t4NVCmWFfRAQOHvXEx3meGYogdwb6wJ7sRs3/tLzkcebp7mz2zEtWDDw029qfSrmba7A
         ExNfCjhMsxSOZ2RATSCJZiVasJ1mravAUmbkdw6PFCU7TM/8rz9wScGSnIjxJsc06Sq0
         sHbM5w/FFXWceqP8h/OQBe8QxzBvo5Ixl8fj6TdECw80Pn9LAWnBC+bv29mIi298b/Cv
         Eshw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id h37si2063212edb.373.2019.03.21.07.20.06
        for <linux-mm@kvack.org>;
        Thu, 21 Mar 2019 07:20:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id EF47180D;
	Thu, 21 Mar 2019 07:20:05 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B345B3F575;
	Thu, 21 Mar 2019 07:20:02 -0700 (PDT)
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
Subject: [PATCH v5 00/19] Convert x86 & arm64 to use generic page walk
Date: Thu, 21 Mar 2019 14:19:34 +0000
Message-Id: <20190321141953.31960-1-steven.price@arm.com>
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
 include/linux/mm.h                           |  20 +-
 mm/pagewalk.c                                |  76 +++-
 18 files changed, 404 insertions(+), 270 deletions(-)

-- 
2.20.1

