Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5F7D48E0003
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 07:54:28 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id 186-v6so12167017pgc.12
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 04:54:28 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d13-v6si4992255pll.337.2018.09.26.04.54.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 26 Sep 2018 04:54:27 -0700 (PDT)
Message-ID: <20180926113623.863696043@infradead.org>
Date: Wed, 26 Sep 2018 13:36:23 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: [PATCH 00/18] my generic mmu_gather patches
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: will.deacon@arm.com, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com
Cc: linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, peterz@infradead.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com, riel@surriel.com, fengguang.wu@intel.com

Hi,

Here is my current stash of generic mmu_gather patches that goes on top of Will's
tlb patches:

  git://git.kernel.org/pub/scm/linux/kernel/git/arm64/linux.git tlb/asm-generic

And they include the s390 patches done by Heiko. At the end of this, there is
not a single arch left with a custom mmu_gather.

I've been slow posting these, because the 0-day bot seems to be having trouble
and I've not been getting the regular cross-build green light emails that I
otherwise rely upon.

I hope to have addressed all the feedback from the last time, and I've added a
bunch of missing Cc's from last time.

Please review with care.

---
 arch/Kconfig                      |   8 +-
 arch/alpha/include/asm/tlb.h      |   2 -
 arch/arc/include/asm/tlb.h        |  32 -----
 arch/arm/include/asm/tlb.h        | 256 +++----------------------------------
 arch/arm64/Kconfig                |   1 -
 arch/arm64/include/asm/tlb.h      |   1 +
 arch/c6x/include/asm/tlb.h        |   1 +
 arch/h8300/include/asm/tlb.h      |   2 -
 arch/hexagon/include/asm/tlb.h    |  12 --
 arch/ia64/include/asm/tlb.h       | 257 +-------------------------------------
 arch/ia64/include/asm/tlbflush.h  |  25 ++++
 arch/ia64/mm/tlb.c                |  23 +++-
 arch/m68k/include/asm/tlb.h       |   1 -
 arch/microblaze/include/asm/tlb.h |   4 +-
 arch/mips/include/asm/tlb.h       |  17 ---
 arch/nds32/include/asm/tlb.h      |  16 ---
 arch/nios2/include/asm/tlb.h      |  14 +--
 arch/openrisc/include/asm/tlb.h   |   6 +-
 arch/parisc/include/asm/tlb.h     |  18 ---
 arch/powerpc/Kconfig              |   2 +
 arch/powerpc/include/asm/tlb.h    |  18 +--
 arch/riscv/include/asm/tlb.h      |   1 +
 arch/s390/Kconfig                 |   2 +
 arch/s390/include/asm/tlb.h       | 130 ++++++-------------
 arch/s390/mm/pgalloc.c            |  63 +---------
 arch/sh/include/asm/pgalloc.h     |   9 ++
 arch/sh/include/asm/tlb.h         | 132 +-------------------
 arch/sparc/Kconfig                |   1 +
 arch/sparc/include/asm/tlb_32.h   |  18 ---
 arch/um/include/asm/tlb.h         | 158 +----------------------
 arch/unicore32/include/asm/tlb.h  |  10 +-
 arch/x86/Kconfig                  |   1 -
 arch/x86/include/asm/tlb.h        |  22 ++--
 arch/x86/include/asm/tlbflush.h   |  12 +-
 arch/x86/mm/tlb.c                 |  17 ++-
 arch/xtensa/include/asm/tlb.h     |  26 ----
 include/asm-generic/tlb.h         | 238 +++++++++++++++++++++++++++++++----
 mm/huge_memory.c                  |   4 +-
 mm/hugetlb.c                      |   2 +-
 mm/madvise.c                      |   2 +-
 mm/memory.c                       |   6 +-
 mm/mmu_gather.c                   | 129 ++++++++++---------
 mm/pgtable-generic.c              |   1 +
 43 files changed, 460 insertions(+), 1240 deletions(-)
