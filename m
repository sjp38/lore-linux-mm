Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 726546B0081
	for <linux-mm@kvack.org>; Thu, 26 Feb 2015 06:35:56 -0500 (EST)
Received: by pablf10 with SMTP id lf10so13286011pab.12
        for <linux-mm@kvack.org>; Thu, 26 Feb 2015 03:35:56 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id h7si79548pdn.131.2015.02.26.03.35.38
        for <linux-mm@kvack.org>;
        Thu, 26 Feb 2015 03:35:39 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 00/17] Add missing __PAGETABLE_{PUD,PMD}_FOLDED defines and introduce CONFIG_PGTABLE_LEVELS
Date: Thu, 26 Feb 2015 13:35:03 +0200
Message-Id: <1424950520-90188-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This is rearrangment of CONFIG_PGTABLE_LEVELS patchset.

The first patch adds all missing __PAGETABLE_{PUD,PMD}_FOLDED defines.
This will fix mm->nr_pmds underflow on affected architectures and should
go into v4.0.

The rest is just a rebase of CONFIG_PGTABLE_LEVELS patchset and can wait
until 4.1.

Kirill A. Shutemov (17):
  mm: add missing __PAGETABLE_{PUD,PMD}_FOLDED defines
  alpha: expose number of page table levels on Kconfig level
  arm64: expose number of page table levels on Kconfig level
  arm: expose number of page table levels on Kconfig level
  ia64: expose number of page table levels on Kconfig level
  m68k: mark PMD folded and expose number of page table levels
  mips: expose number of page table levels on Kconfig level
  parisc: expose number of page table levels on Kconfig level
  powerpc: expose number of page table levels on Kconfig level
  s390: expose number of page table levels
  sh: expose number of page table levels
  sparc: expose number of page table levels
  tile: expose number of page table levels
  um: expose number of page table levels
  x86: expose number of page table levels on Kconfig level
  mm: define default PGTABLE_LEVELS to two
  mm: do not add nr_pmds into mm_struct if PMD is folded

 arch/Kconfig                                |  4 ++++
 arch/alpha/Kconfig                          |  4 ++++
 arch/arm/Kconfig                            |  5 +++++
 arch/arm64/Kconfig                          | 14 +++++++-------
 arch/arm64/include/asm/kvm_mmu.h            |  4 ++--
 arch/arm64/include/asm/page.h               |  4 ++--
 arch/arm64/include/asm/pgalloc.h            |  8 ++++----
 arch/arm64/include/asm/pgtable-hwdef.h      |  6 +++---
 arch/arm64/include/asm/pgtable-types.h      | 12 ++++++------
 arch/arm64/include/asm/pgtable.h            |  8 ++++----
 arch/arm64/include/asm/tlb.h                |  4 ++--
 arch/arm64/mm/mmu.c                         |  4 ++--
 arch/frv/include/asm/pgtable.h              |  2 ++
 arch/ia64/Kconfig                           | 18 +++++-------------
 arch/ia64/include/asm/page.h                |  4 ++--
 arch/ia64/include/asm/pgalloc.h             |  4 ++--
 arch/ia64/include/asm/pgtable.h             | 12 ++++++------
 arch/ia64/kernel/ivt.S                      | 12 ++++++------
 arch/ia64/kernel/machine_kexec.c            |  4 ++--
 arch/m32r/include/asm/pgtable-2level.h      |  1 +
 arch/m68k/Kconfig                           |  4 ++++
 arch/m68k/include/asm/pgtable_mm.h          |  2 ++
 arch/mips/Kconfig                           |  5 +++++
 arch/mn10300/include/asm/pgtable.h          |  2 ++
 arch/parisc/Kconfig                         |  5 +++++
 arch/parisc/include/asm/pgalloc.h           |  2 +-
 arch/parisc/include/asm/pgtable.h           | 17 ++++++++---------
 arch/parisc/kernel/entry.S                  |  4 ++--
 arch/parisc/kernel/head.S                   |  4 ++--
 arch/parisc/mm/init.c                       |  2 +-
 arch/powerpc/Kconfig                        |  6 ++++++
 arch/s390/Kconfig                           |  5 +++++
 arch/s390/include/asm/pgtable.h             |  2 ++
 arch/sh/Kconfig                             |  4 ++++
 arch/sparc/Kconfig                          |  4 ++++
 arch/tile/Kconfig                           |  5 +++++
 arch/um/Kconfig.um                          |  5 +++++
 arch/x86/Kconfig                            |  6 ++++++
 arch/x86/include/asm/paravirt.h             |  8 ++++----
 arch/x86/include/asm/paravirt_types.h       |  8 ++++----
 arch/x86/include/asm/pgalloc.h              |  8 ++++----
 arch/x86/include/asm/pgtable-2level_types.h |  1 -
 arch/x86/include/asm/pgtable-3level_types.h |  2 --
 arch/x86/include/asm/pgtable.h              |  8 ++++----
 arch/x86/include/asm/pgtable_64_types.h     |  1 -
 arch/x86/include/asm/pgtable_types.h        |  4 ++--
 arch/x86/kernel/paravirt.c                  |  6 +++---
 arch/x86/mm/pgtable.c                       | 14 +++++++-------
 arch/x86/xen/mmu.c                          | 14 +++++++-------
 include/asm-generic/pgtable.h               |  5 +++++
 include/linux/mm_types.h                    |  2 ++
 include/trace/events/xen.h                  |  2 +-
 52 files changed, 183 insertions(+), 118 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
