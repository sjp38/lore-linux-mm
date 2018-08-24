Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 669426B30F4
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 14:23:02 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id f13-v6so6184400pgs.15
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 11:23:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 92-v6sor2674352pli.51.2018.08.24.11.23.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 Aug 2018 11:23:01 -0700 (PDT)
Date: Fri, 24 Aug 2018 11:22:59 -0700
From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [RFC PATCH 2/2] mm: mmu_notifier fix for tlb_end_vma (build
 failures)
Message-ID: <20180824182259.GA18477@roeck-us.net>
References: <20180823084709.19717-1-npiggin@gmail.com>
 <20180823084709.19717-3-npiggin@gmail.com>
 <20180824130722.GA31409@roeck-us.net>
 <20180824131026.GB11868@brain-police>
 <20180824132419.GA9983@roeck-us.net>
 <20180824133427.GC11868@brain-police>
 <20180824135048.GF11868@brain-police>
 <7d0111f4-c369-43a8-72c6-1a7390cdebdd@roeck-us.net>
 <20180824142532.GG11868@brain-police>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180824142532.GG11868@brain-police>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Nicholas Piggin <npiggin@gmail.com>, Peter Zijlstra <peterz@infradead.org>, torvalds@linux-foundation.org, luto@kernel.org, x86@kernel.org, bp@alien8.de, riel@surriel.com, jannh@google.com, ascannell@google.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, linux-arch@vger.kernel.org, Palmer Dabbelt <palmer@sifive.com>, linux-riscv@lists.infradead.org

On Fri, Aug 24, 2018 at 03:25:33PM +0100, Will Deacon wrote:
> On Fri, Aug 24, 2018 at 07:06:51AM -0700, Guenter Roeck wrote:
> > On 08/24/2018 06:50 AM, Will Deacon wrote:
> > 
> > >>-#include <asm-generic/tlb.h>
> > >>+struct mmu_gather;
> > >>  static inline void tlb_flush(struct mmu_gather *tlb)
> > >>  {
> > >>  	flush_tlb_mm(tlb->mm);
> > >
> > >Bah, didn't spot the dereference so this won't work either. You basically
> > >just need to copy what I did for arm64 in d475fac95779.
> > >
> > 
> > Yes, this seems to work. It doesn't really need "struct mmu_gather;" -
> > I assume that is included from elsewhere - but I added it to be safe.
> 
> struct mmu_gather comes in via asm-generic/tlb.h.
> 
>From linux/mm.h, really, which happens to be included before
asm/tlb.h is included (see arch/riscv/include/asm/pgalloc.h).
I kept it to be future-proof.

> > Can you send a full patch, or do you want me to do it ?
> 
> I'm evidently incapable of writing code today, so please go ahead :)
> 
Done. We'll see if I am any better.

Guenter
