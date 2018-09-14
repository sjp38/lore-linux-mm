Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9EDC38E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 12:56:32 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id c18-v6so10243151oiy.3
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 09:56:32 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q62-v6si3698174oia.209.2018.09.14.09.56.31
        for <linux-mm@kvack.org>;
        Fri, 14 Sep 2018 09:56:31 -0700 (PDT)
Date: Fri, 14 Sep 2018 17:56:48 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [RFC][PATCH 04/11] asm-generic/tlb: Provide generic VIPT cache
 flush
Message-ID: <20180914165648.GI6236@arm.com>
References: <20180913092110.817204997@infradead.org>
 <20180913092812.071989585@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180913092812.071989585@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com, David Miller <davem@davemloft.net>, Guan Xuetao <gxt@pku.edu.cn>

On Thu, Sep 13, 2018 at 11:21:14AM +0200, Peter Zijlstra wrote:
> The one obvious thing SH and ARM want is a sensible default for
> tlb_start_vma(). (also: https://lkml.org/lkml/2004/1/15/6 )
> 
> Avoid all VIPT architectures providing their own tlb_start_vma()
> implementation and rely on architectures to provide a no-op
> flush_cache_range() when it is not relevant.
> 
> The below makes tlb_start_vma() default to flush_cache_range(), which
> should be right and sufficient. The only exceptions that I found where
> (oddly):
> 
>   - m68k-mmu
>   - sparc64
>   - unicore
> 
> Those architectures appear to have flush_cache_range(), but their
> current tlb_start_vma() does not call it.
> 
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Nick Piggin <npiggin@gmail.com>
> Cc: David Miller <davem@davemloft.net>
> Cc: Guan Xuetao <gxt@pku.edu.cn>
> Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
> ---
>  arch/arc/include/asm/tlb.h      |    9 ---------
>  arch/mips/include/asm/tlb.h     |    9 ---------
>  arch/nds32/include/asm/tlb.h    |    6 ------
>  arch/nios2/include/asm/tlb.h    |   10 ----------
>  arch/parisc/include/asm/tlb.h   |    5 -----
>  arch/sparc/include/asm/tlb_32.h |    5 -----
>  arch/xtensa/include/asm/tlb.h   |    9 ---------
>  include/asm-generic/tlb.h       |   19 +++++++++++--------
>  8 files changed, 11 insertions(+), 61 deletions(-)

LGTM and makes no difference to arm/arm64:

Acked-by: Will Deacon <will.deacon@arm.com>

Will
