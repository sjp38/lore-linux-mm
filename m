Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 478F66B7E9A
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 09:43:47 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id c18-v6so17018423oiy.3
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 06:43:47 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b135-v6si5865143oii.71.2018.09.07.06.43.45
        for <linux-mm@kvack.org>;
        Fri, 07 Sep 2018 06:43:46 -0700 (PDT)
Date: Fri, 7 Sep 2018 14:44:00 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [RFC PATCH 1/2] mm: move tlb_table_flush to tlb_flush_mmu_free
Message-ID: <20180907134359.GA12187@arm.com>
References: <20180823084709.19717-1-npiggin@gmail.com>
 <20180823084709.19717-2-npiggin@gmail.com>
 <fa7c625dfbbe103b37bc3ab5ea4b7283fd13b998.camel@surriel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fa7c625dfbbe103b37bc3ab5ea4b7283fd13b998.camel@surriel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@surriel.com>
Cc: Nicholas Piggin <npiggin@gmail.com>, Peter Zijlstra <peterz@infradead.org>, torvalds@linux-foundation.org, luto@kernel.org, x86@kernel.org, bp@alien8.de, jannh@google.com, ascannell@google.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, linux-arch@vger.kernel.org

On Thu, Sep 06, 2018 at 04:29:59PM -0400, Rik van Riel wrote:
> On Thu, 2018-08-23 at 18:47 +1000, Nicholas Piggin wrote:
> > There is no need to call this from tlb_flush_mmu_tlbonly, it
> > logically belongs with tlb_flush_mmu_free. This allows some
> > code consolidation with a subsequent fix.
> > 
> > Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
> 
> Reviewed-by: Rik van Riel <riel@surriel.com>
> 
> This patch also fixes an infinite recursion bug
> with CONFIG_HAVE_RCU_TABLE_FREE enabled, which
> has this call trace:
> 
> tlb_table_flush
>   -> tlb_table_invalidate
>      -> tlb_flush_mmu_tlbonly
>         -> tlb_table_flush
>            -> ... (infinite recursion)
> 
> This should probably be applied sooner rather than
> later.

It's already in mainline with a cc stable afaict.

Will
