Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 813116B0003
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 09:13:58 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id e6-v6so17057292pge.5
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 06:13:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p7-v6sor4663480pga.39.2018.10.16.06.13.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 16 Oct 2018 06:13:57 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
Subject: [PATCH v2 0/5] mm: dirty/accessed pte optimisations
Date: Tue, 16 Oct 2018 23:13:38 +1000
Message-Id: <20181016131343.20556-1-npiggin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nicholas Piggin <npiggin@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, ppc-dev <linuxppc-dev@lists.ozlabs.org>, Ley Foon Tan <ley.foon.tan@intel.com>

Since v1 I fixed the hang in nios2, split the fork patch into two
as Linus asked, and added hugetlb code for the "don't bother write
protecting already writeprotected" patch.

Please consider this for more cooking in -mm.

Thanks,
Nick

Nicholas Piggin (5):
  nios2: update_mmu_cache clear the old entry from the TLB
  mm/cow: don't bother write protecting already write-protected huge
    pages
  mm/cow: optimise pte accessed bit handling in fork
  mm/cow: optimise pte dirty bit handling in fork
  mm: optimise pte dirty/accessed bit setting by demand based pte
    insertion

 arch/nios2/mm/cacheflush.c |  2 ++
 mm/huge_memory.c           | 24 ++++++++++++++++--------
 mm/hugetlb.c               |  2 +-
 mm/memory.c                | 19 +++++++++++--------
 mm/vmscan.c                |  8 ++++++++
 5 files changed, 38 insertions(+), 17 deletions(-)

-- 
2.18.0
