Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 303AA6B4042
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 07:29:02 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id h3-v6so10708480pgc.8
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 04:29:02 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j2-v6si14508919pfc.102.2018.08.27.04.29.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 27 Aug 2018 04:29:00 -0700 (PDT)
Date: Mon, 27 Aug 2018 13:28:35 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: removig ia64, was: Re: [PATCH 3/4] mm/tlb, x86/mm: Support
 invalidating TLB caches for RCU_TABLE_FREE
Message-ID: <20180827112835.GC24124@hirez.programming.kicks-ass.net>
References: <CA+55aFxneZTFxxxAjLZmj92VUJg6z7hERxJ2cHoth-GC0RuELw@mail.gmail.com>
 <776104d4c8e4fc680004d69e3a4c2594b638b6d1.camel@au1.ibm.com>
 <CA+55aFzM77G9-Q6LboPLJ=5gHma66ZQKiMGCMqXoKABirdF98w@mail.gmail.com>
 <20180823133958.GA1496@brain-police>
 <20180824084717.GK24124@hirez.programming.kicks-ass.net>
 <20180824113214.GK24142@hirez.programming.kicks-ass.net>
 <20180824113953.GL24142@hirez.programming.kicks-ass.net>
 <20180827150008.13bce08f@roar.ozlabs.ibm.com>
 <20180827074701.GW24124@hirez.programming.kicks-ass.net>
 <20180827085708.GA27172@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180827085708.GA27172@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Nicholas Piggin <npiggin@gmail.com>, Will Deacon <will.deacon@arm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Benjamin Herrenschmidt <benh@au1.ibm.com>, Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, Tony Luck <tony.luck@intel.com>, Fenghua Yu <fenghua.yu@intel.com>, linux-ia64@vger.kernel.org

On Mon, Aug 27, 2018 at 01:57:08AM -0700, Christoph Hellwig wrote:
> On Mon, Aug 27, 2018 at 09:47:01AM +0200, Peter Zijlstra wrote:
> > sh is trivial, arm seems doable, with a bit of luck we can do 'rm -rf
> > arch/ia64' leaving us with s390.
> 
> Is removing ia64 a serious plan?

I 'joked' about it a while ago on IRC, and aegl reacted that it might
not be entirely unreasonable.

> It is the cause for a fair share of
> oddities in dma lang, and I did not have much luck getting maintainer
> replies lately, but I didn't know of a plan to get rid of it.
> 
> What is the state of people still using ia64 mainline kernels vs just
> old distros in the still existing machines?

Both arjan and aegl said that the vast majority of people still running
ia64 machines run old distros.
