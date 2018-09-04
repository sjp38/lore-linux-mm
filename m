Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5BC6A6B6D4E
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 07:45:21 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id l14-v6so3811761oii.9
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 04:45:21 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v82-v6si13750864oig.99.2018.09.04.04.45.20
        for <linux-mm@kvack.org>;
        Tue, 04 Sep 2018 04:45:20 -0700 (PDT)
From: Will Deacon <will.deacon@arm.com>
Subject: [PATCH v2 0/5] Extend and consolidate mmu_gather into new file
Date: Tue,  4 Sep 2018 12:45:28 +0100
Message-Id: <1536061533-16188-1-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: peterz@infradead.org, npiggin@gmail.com, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, aneesh.kumar@linux.vnet.ibm.com

Hi all,

This series builds on the core changes I previously posted here:

  rfc:	http://lists.infradead.org/pipermail/linux-arm-kernel/2018-August/597821.html
  v1:	http://lists.infradead.org/pipermail/linux-arm-kernel/2018-August/598919.html

The main changes are:

  * Move the mmu_gather bits out of memory.c and into their own file
    (looped in the mm people for this)

  * Add a MAINTAINERS entry for the new file, and all tlb.h headers.
    If any mm developers would like to be included here as well, please
    just ask.

I'd like to queue these patches on their own branch in the arm64 git so
that others can develop on top of them for the next merge window. Peter
and Nick have both expressed an interest in that, and I already have a
bunch of arm64 optimisations on top which I posted previously.

Cheers,

Will

--->8

Peter Zijlstra (2):
  asm-generic/tlb: Track freeing of page-table directories in struct
    mmu_gather
  mm/memory: Move mmu_gather and TLB invalidation code into its own file

Will Deacon (3):
  asm-generic/tlb: Guard with #ifdef CONFIG_MMU
  asm-generic/tlb: Track which levels of the page tables have been
    cleared
  MAINTAINERS: Add entry for MMU GATHER AND TLB INVALIDATION

 MAINTAINERS               |  12 +++
 include/asm-generic/tlb.h |  86 ++++++++++++---
 mm/Makefile               |   6 +-
 mm/memory.c               | 247 -------------------------------------------
 mm/mmu_gather.c           | 259 ++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 348 insertions(+), 262 deletions(-)
 create mode 100644 mm/mmu_gather.c

-- 
2.1.4
