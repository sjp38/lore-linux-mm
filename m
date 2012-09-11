Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 6EF2F6B00CA
	for <linux-mm@kvack.org>; Tue, 11 Sep 2012 12:47:23 -0400 (EDT)
From: Will Deacon <will.deacon@arm.com>
Subject: [PATCH 0/3] Minor changes to common hugetlb code for ARM
Date: Tue, 11 Sep 2012 17:47:13 +0100
Message-Id: <1347382036-18455-1-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, akpm@linux-foundation.org, mhocko@suse.cz, Will Deacon <will.deacon@arm.com>

Hello,

A few changes are required to common hugetlb code before the ARM support
can be merged. I posted the main one previously, which has been picked up
by akpm:

  http://marc.info/?l=linux-mm&m=134573987631394&w=2

The remaining three patches (included here) are all fairly minor but do
affect other architectures.

All comments welcome,

Will

Catalin Marinas (2):
  mm: thp: Fix the pmd_clear() arguments in pmdp_get_and_clear()
  mm: thp: Fix the update_mmu_cache() last argument passing in
    mm/huge_memory.c

Steve Capper (1):
  mm: Introduce HAVE_ARCH_TRANSPARENT_HUGEPAGE

 arch/x86/Kconfig              |    4 ++++
 include/asm-generic/pgtable.h |    2 +-
 mm/Kconfig                    |    2 +-
 mm/huge_memory.c              |    6 +++---
 4 files changed, 9 insertions(+), 5 deletions(-)

-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
