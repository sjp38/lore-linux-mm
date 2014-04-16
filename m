Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id A92E76B0070
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 07:46:51 -0400 (EDT)
Received: by mail-wi0-f179.google.com with SMTP id z2so1227577wiv.0
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 04:46:50 -0700 (PDT)
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
        by mx.google.com with ESMTPS id ch10si7378596wjc.135.2014.04.16.04.46.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Apr 2014 04:46:50 -0700 (PDT)
Received: by mail-we0-f171.google.com with SMTP id t61so10575047wes.2
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 04:46:49 -0700 (PDT)
From: Steve Capper <steve.capper@linaro.org>
Subject: [PATCH V2 0/5] Huge pages for short descriptors on ARM
Date: Wed, 16 Apr 2014 12:46:38 +0100
Message-Id: <1397648803-15961-1-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@arm.linux.org.uk, akpm@linux-foundation.org
Cc: will.deacon@arm.com, catalin.marinas@arm.com, robherring2@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, gerald.schaefer@de.ibm.com, Steve Capper <steve.capper@linaro.org>

Hello,
This series brings HugeTLB pages and Transparent Huge Pages (THP) to
ARM on short descriptors.

Russell, Andrew,
I would like to get this in next (and hopefully 3.16 if no problems
arise) if that sounds reasonable?

There's one patch at the beginning of the series for mm:
  mm: hugetlb: Introduce huge_pte_{page,present,young}
This has been tested on ARM and s390 and should compile out for other
architectures.

The rest of the series targets arch/arm.

I've bumped the series to V2 as it was rebased (and tested against)
v3.15-rc1. On ARM the libhugetlbfs test suite, some THP PROT_NONE
tests and the recursive execve test all passed successfully.

Thanks,
--
Steve


Steve Capper (5):
  mm: hugetlb: Introduce huge_pte_{page,present,young}
  arm: mm: Adjust the parameters for __sync_icache_dcache
  arm: mm: Make mmu_gather aware of huge pages
  arm: mm: HugeTLB support for non-LPAE systems
  arm: mm: Add Transparent HugePage support for non-LPAE

 arch/arm/Kconfig                      |   4 +-
 arch/arm/include/asm/hugetlb-2level.h | 136 ++++++++++++++++++++++++++++++++++
 arch/arm/include/asm/hugetlb-3level.h |   6 ++
 arch/arm/include/asm/hugetlb.h        |  10 +--
 arch/arm/include/asm/pgtable-2level.h | 129 +++++++++++++++++++++++++++++++-
 arch/arm/include/asm/pgtable-3level.h |   3 +-
 arch/arm/include/asm/pgtable.h        |   9 +--
 arch/arm/include/asm/tlb.h            |  14 +++-
 arch/arm/kernel/head.S                |  10 ++-
 arch/arm/mm/fault.c                   |  13 ----
 arch/arm/mm/flush.c                   |   9 +--
 arch/arm/mm/fsr-2level.c              |   4 +-
 arch/arm/mm/hugetlbpage.c             |   2 +-
 arch/arm/mm/mmu.c                     |  51 +++++++++++++
 arch/s390/include/asm/hugetlb.h       |  15 ++++
 include/asm-generic/hugetlb.h         |  15 ++++
 mm/hugetlb.c                          |  22 +++---
 17 files changed, 399 insertions(+), 53 deletions(-)
 create mode 100644 arch/arm/include/asm/hugetlb-2level.h

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
