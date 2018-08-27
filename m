Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id F38736B3F8C
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 04:21:06 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id x85-v6so11337559pfe.13
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 01:21:06 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f23-v6si12523717pgv.383.2018.08.27.01.21.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 27 Aug 2018 01:21:06 -0700 (PDT)
Date: Mon, 27 Aug 2018 10:20:45 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 3/4] mm/tlb, x86/mm: Support invalidating TLB caches for
 RCU_TABLE_FREE
Message-ID: <20180827082045.GA24124@hirez.programming.kicks-ass.net>
References: <776104d4c8e4fc680004d69e3a4c2594b638b6d1.camel@au1.ibm.com>
 <CA+55aFzM77G9-Q6LboPLJ=5gHma66ZQKiMGCMqXoKABirdF98w@mail.gmail.com>
 <20180823133958.GA1496@brain-police>
 <20180824084717.GK24124@hirez.programming.kicks-ass.net>
 <20180824113214.GK24142@hirez.programming.kicks-ass.net>
 <20180824113953.GL24142@hirez.programming.kicks-ass.net>
 <20180827150008.13bce08f@roar.ozlabs.ibm.com>
 <20180827074701.GW24124@hirez.programming.kicks-ass.net>
 <20180827180458.4af9b2ac@roar.ozlabs.ibm.com>
 <4ef8a2aa44db971340b0bcc4f73d639455dd4282.camel@kernel.crashing.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4ef8a2aa44db971340b0bcc4f73d639455dd4282.camel@kernel.crashing.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Nicholas Piggin <npiggin@gmail.com>, Will Deacon <will.deacon@arm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>

On Mon, Aug 27, 2018 at 06:09:50PM +1000, Benjamin Herrenschmidt wrote:

> Sadly our architecture requires a precise match between the page size
> specified in the tlbie instruction and the entry in the TLB or it won't
> be flushed.

Argh.. OK I see. That is rather unfortunate and does seem to require
something along the lines of tlb_remove_check_page_size_change().
