Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id CC0656B3022
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 10:25:42 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id j5-v6so7747064oiw.13
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 07:25:42 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id h82-v6si5801626oia.382.2018.08.24.07.25.41
        for <linux-mm@kvack.org>;
        Fri, 24 Aug 2018 07:25:41 -0700 (PDT)
Date: Fri, 24 Aug 2018 15:25:33 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [RFC PATCH 2/2] mm: mmu_notifier fix for tlb_end_vma (build
 failures)
Message-ID: <20180824142532.GG11868@brain-police>
References: <20180823084709.19717-1-npiggin@gmail.com>
 <20180823084709.19717-3-npiggin@gmail.com>
 <20180824130722.GA31409@roeck-us.net>
 <20180824131026.GB11868@brain-police>
 <20180824132419.GA9983@roeck-us.net>
 <20180824133427.GC11868@brain-police>
 <20180824135048.GF11868@brain-police>
 <7d0111f4-c369-43a8-72c6-1a7390cdebdd@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7d0111f4-c369-43a8-72c6-1a7390cdebdd@roeck-us.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: Nicholas Piggin <npiggin@gmail.com>, Peter Zijlstra <peterz@infradead.org>, torvalds@linux-foundation.org, luto@kernel.org, x86@kernel.org, bp@alien8.de, riel@surriel.com, jannh@google.com, ascannell@google.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, linux-arch@vger.kernel.org, Palmer Dabbelt <palmer@sifive.com>, linux-riscv@lists.infradead.org

On Fri, Aug 24, 2018 at 07:06:51AM -0700, Guenter Roeck wrote:
> On 08/24/2018 06:50 AM, Will Deacon wrote:
> 
> >>-#include <asm-generic/tlb.h>
> >>+struct mmu_gather;
> >>  static inline void tlb_flush(struct mmu_gather *tlb)
> >>  {
> >>  	flush_tlb_mm(tlb->mm);
> >
> >Bah, didn't spot the dereference so this won't work either. You basically
> >just need to copy what I did for arm64 in d475fac95779.
> >
> 
> Yes, this seems to work. It doesn't really need "struct mmu_gather;" -
> I assume that is included from elsewhere - but I added it to be safe.

struct mmu_gather comes in via asm-generic/tlb.h.

> Can you send a full patch, or do you want me to do it ?

I'm evidently incapable of writing code today, so please go ahead :)

Will
