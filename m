Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1E5426B2FEF
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 09:26:15 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id h65-v6so5776916pfk.18
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 06:26:15 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTP id s184-v6si6773978pgb.123.2018.08.24.06.26.14
        for <linux-mm@kvack.org>;
        Fri, 24 Aug 2018 06:26:14 -0700 (PDT)
Date: Fri, 24 Aug 2018 15:14:40 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 3/4] mm/tlb, x86/mm: Support invalidating TLB caches for
 RCU_TABLE_FREE
Message-ID: <20180824131440.GN24142@hirez.programming.kicks-ass.net>
References: <20180822153012.173508681@infradead.org>
 <20180822154046.823850812@infradead.org>
 <20180822155527.GF24124@hirez.programming.kicks-ass.net>
 <20180823134525.5f12b0d3@roar.ozlabs.ibm.com>
 <CA+55aFxneZTFxxxAjLZmj92VUJg6z7hERxJ2cHoth-GC0RuELw@mail.gmail.com>
 <776104d4c8e4fc680004d69e3a4c2594b638b6d1.camel@au1.ibm.com>
 <20180824083556.GI24124@hirez.programming.kicks-ass.net>
 <20180824131332.GM24142@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180824131332.GM24142@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@au1.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@gmail.com>, Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Will Deacon <will.deacon@arm.com>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Fri, Aug 24, 2018 at 03:13:32PM +0200, Peter Zijlstra wrote:
> + *  HAVE_RCU_TABLE_FREE
> + *
> + *  This provides tlb_remove_table(), to be used instead of tlb_remove_page()
> + *  for page directores (__p*_free_tlb()). This provides separate freeing of
> + *  the page-table pages themselves in a semi-RCU fashion (see comment below).
> + *  Useful if your architecture doesn't use IPIs for remote TLB invalidates
> + *  and therefore doesn't naturally serialize with software page-table walkers.
> + *
> + *  HAVE_RCU_TABLE_INVALIDATE
> + *
> + *  This makes HAVE_RCU_TABLE_FREE call tlb_flush_mmu_tlbonly() before freeing
> + *  the page-table pages. Required if you use HAVE_RCU_TABLE_FREE and your
> + *  architecture uses the Linux page-tables natively.

Writing that also made me think we maybe should've negated that option.
