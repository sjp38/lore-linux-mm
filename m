Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7469E6B02B5
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 10:06:53 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id w1-v6so5428928ply.12
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 07:06:53 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f33-v6sor4020847pgl.432.2018.07.25.07.06.52
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Jul 2018 07:06:52 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
Subject: [RFC PATCH 0/4] mm: mmu_gather changes to support explicit paging
Date: Thu, 26 Jul 2018 00:06:37 +1000
Message-Id: <20180725140641.30372-1-npiggin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Nicholas Piggin <npiggin@gmail.com>, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org, linux-arm-kernel@lists.infradead.org

The first 3 patches in this series are some generic mm changes I
would like to make, including a possible fix which may(?) be needed
for ARM64. Other than the bugfix, these first 3 patches should not
change anything so hopefully they aren't too controversial.

The powerpc patch is also there for reference. 

Thanks,
Nick

Nicholas Piggin (4):
  mm: move tlb_table_flush to tlb_flush_mmu_free
  mm: mmu_notifier fix for tlb_end_vma
  mm: allow arch to have tlb_flush caled on an empty TLB range
  powerpc/64s/radix: optimise TLB flush with precise TLB ranges in
    mmu_gather

 arch/powerpc/include/asm/tlb.h | 34 +++++++++++++++++++++++++++++++++
 arch/powerpc/mm/tlb-radix.c    | 10 ++++++++++
 include/asm-generic/tlb.h      | 35 ++++++++++++++++++++++++++++++----
 mm/memory.c                    | 14 ++------------
 4 files changed, 77 insertions(+), 16 deletions(-)

-- 
2.17.0
