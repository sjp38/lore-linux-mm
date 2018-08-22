Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id ECF926B2677
	for <linux-mm@kvack.org>; Wed, 22 Aug 2018 17:34:40 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id w23-v6so2593675iob.18
        for <linux-mm@kvack.org>; Wed, 22 Aug 2018 14:34:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x11-v6sor1231997itx.11.2018.08.22.14.34.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 22 Aug 2018 14:34:39 -0700 (PDT)
MIME-Version: 1.0
References: <20180822153012.173508681@infradead.org> <20180822154046.823850812@infradead.org>
In-Reply-To: <20180822154046.823850812@infradead.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 22 Aug 2018 14:34:27 -0700
Message-ID: <CA+55aFykjambbbvwap2C=B7yKzpy5-W6OiYG16E1RE7QLzODtg@mail.gmail.com>
Subject: Re: [PATCH 3/4] mm/tlb, x86/mm: Support invalidating TLB caches for RCU_TABLE_FREE
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Will Deacon <will.deacon@arm.com>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Nick Piggin <npiggin@gmail.com>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Wed, Aug 22, 2018 at 8:46 AM Peter Zijlstra <peterz@infradead.org> wrote:
>
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -180,6 +180,7 @@ config X86
>         select HAVE_PERF_REGS
>         select HAVE_PERF_USER_STACK_DUMP
>         select HAVE_RCU_TABLE_FREE
> +       select HAVE_RCU_TABLE_INVALIDATE        if HAVE_RCU_TABLE_FREE

This is confusing. First you select HAVE_RCU_TABLE_FREE
unconditionally, and then you select HAVE_RCU_TABLE_INVALIDATE based
on that unconditional variable.

I can see why you do it, but that's because I see the next patch. On
its own it just looks like you have a drinking problem.

That said, I was waiting to see if this patch-set would get any
comments before applying it, but it's been mostly crickets... So I
think I'll just apply it and get this issue over and done with.

              Linus
