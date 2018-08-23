Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2BDBC6B2922
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 04:47:24 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id w23-v6so2584659pgv.1
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 01:47:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i90-v6sor1232761pfi.29.2018.08.23.01.47.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Aug 2018 01:47:22 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
Subject: [RFC PATCH 0/2] minor mmu_gather patches
Date: Thu, 23 Aug 2018 18:47:07 +1000
Message-Id: <20180823084709.19717-1-npiggin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Nicholas Piggin <npiggin@gmail.com>, torvalds@linux-foundation.org, luto@kernel.org, x86@kernel.org, bp@alien8.de, will.deacon@arm.com, riel@surriel.com, jannh@google.com, ascannell@google.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, linux-arch@vger.kernel.org

These are split from some patches I posted a while back, I was going
to take a look and revive the series again after your fixes go in,
but having another look, it may be that your "[PATCH 3/4] mm/tlb,
x86/mm: Support invalidating TLB caches for RCU_TABLE_FREE" becomes
easier after my patch 1.

And I'm not convinced patch 2 is not a real bug at least for ARM64,
so it may be possible to squeeze it in if it's reviewed very
carefully (I need to actually reproduce and trace it).

So not signed off by yet, but if you think it might be worth doing
these with your changes, it could be a slightly cleaner end result?

Thanks,
Nick


Nicholas Piggin (2):
  mm: move tlb_table_flush to tlb_flush_mmu_free
  mm: mmu_notifier fix for tlb_end_vma

 include/asm-generic/tlb.h | 17 +++++++++++++----
 mm/memory.c               | 14 ++------------
 2 files changed, 15 insertions(+), 16 deletions(-)

-- 
2.17.0
