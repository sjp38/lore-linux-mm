Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4975E8E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 12:56:28 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id u40-v6so4303736otc.0
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 09:56:28 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a3-v6si3758099oif.1.2018.09.14.09.56.26
        for <linux-mm@kvack.org>;
        Fri, 14 Sep 2018 09:56:27 -0700 (PDT)
Date: Fri, 14 Sep 2018 17:56:43 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [RFC][PATCH 02/11] asm-generic/tlb: Provide
 HAVE_MMU_GATHER_PAGE_SIZE
Message-ID: <20180914165643.GH6236@arm.com>
References: <20180913092110.817204997@infradead.org>
 <20180913092811.955706111@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180913092811.955706111@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com

On Thu, Sep 13, 2018 at 11:21:12AM +0200, Peter Zijlstra wrote:
> Move the mmu_gather::page_size things into the generic code instead of
> powerpc specific bits.
> 
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Nick Piggin <npiggin@gmail.com>
> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> ---
>  arch/Kconfig                   |    3 +++
>  arch/arm/include/asm/tlb.h     |    3 +--
>  arch/ia64/include/asm/tlb.h    |    3 +--
>  arch/powerpc/Kconfig           |    1 +
>  arch/powerpc/include/asm/tlb.h |   17 -----------------
>  arch/s390/include/asm/tlb.h    |    4 +---
>  arch/sh/include/asm/tlb.h      |    4 +---
>  arch/um/include/asm/tlb.h      |    4 +---
>  include/asm-generic/tlb.h      |   25 +++++++++++++------------
>  mm/huge_memory.c               |    4 ++--
>  mm/hugetlb.c                   |    2 +-
>  mm/madvise.c                   |    2 +-
>  mm/memory.c                    |    4 ++--
>  mm/mmu_gather.c                |    5 +++++
>  14 files changed, 33 insertions(+), 48 deletions(-)

Looks fine to me, but I hope we can remove this option altogether in future:

Acked-by: Will Deacon <will.deacon@arm.com>

Will
