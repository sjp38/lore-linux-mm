Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id A20776B3FA4
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 04:57:34 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i68-v6so11376006pfb.9
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 01:57:34 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e20-v6si2210744pgm.172.2018.08.27.01.57.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 27 Aug 2018 01:57:33 -0700 (PDT)
Date: Mon, 27 Aug 2018 01:57:08 -0700
From: Christoph Hellwig <hch@infradead.org>
Subject: removig ia64, was: Re: [PATCH 3/4] mm/tlb, x86/mm: Support
 invalidating TLB caches for RCU_TABLE_FREE
Message-ID: <20180827085708.GA27172@infradead.org>
References: <20180823134525.5f12b0d3@roar.ozlabs.ibm.com>
 <CA+55aFxneZTFxxxAjLZmj92VUJg6z7hERxJ2cHoth-GC0RuELw@mail.gmail.com>
 <776104d4c8e4fc680004d69e3a4c2594b638b6d1.camel@au1.ibm.com>
 <CA+55aFzM77G9-Q6LboPLJ=5gHma66ZQKiMGCMqXoKABirdF98w@mail.gmail.com>
 <20180823133958.GA1496@brain-police>
 <20180824084717.GK24124@hirez.programming.kicks-ass.net>
 <20180824113214.GK24142@hirez.programming.kicks-ass.net>
 <20180824113953.GL24142@hirez.programming.kicks-ass.net>
 <20180827150008.13bce08f@roar.ozlabs.ibm.com>
 <20180827074701.GW24124@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180827074701.GW24124@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Nicholas Piggin <npiggin@gmail.com>, Will Deacon <will.deacon@arm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Benjamin Herrenschmidt <benh@au1.ibm.com>, Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

On Mon, Aug 27, 2018 at 09:47:01AM +0200, Peter Zijlstra wrote:
> sh is trivial, arm seems doable, with a bit of luck we can do 'rm -rf
> arch/ia64' leaving us with s390.

Is removing ia64 a serious plan?  It is the cause for a fair share of
oddities in dma lang, and I did not have much luck getting maintainer
replies lately, but I didn't know of a plan to get rid of it.

What is the state of people still using ia64 mainline kernels vs just
old distros in the still existing machines?
