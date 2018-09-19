Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1F6298E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 07:33:14 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id k143-v6so7225891ite.5
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 04:33:14 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id n44-v6si15317648jak.27.2018.09.19.04.33.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 19 Sep 2018 04:33:13 -0700 (PDT)
Date: Wed, 19 Sep 2018 13:33:06 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH 01/11] asm-generic/tlb: Provide a comment
Message-ID: <20180919113305.GC24124@hirez.programming.kicks-ass.net>
References: <20180913092110.817204997@infradead.org>
 <20180913092811.894806629@infradead.org>
 <20180914164857.GG6236@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180914164857.GG6236@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com

On Fri, Sep 14, 2018 at 05:48:57PM +0100, Will Deacon wrote:

> > + *  - tlb_change_page_size()
> 
> This doesn't seem to exist in my tree.
> [since realised you rename to it in the next patch]
> 

> > + * Additionally there are a few opt-in features:
> > + *
> > + *  HAVE_MMU_GATHER_PAGE_SIZE
> > + *
> > + *  This ensures we call tlb_flush() every time tlb_change_page_size() actually
> > + *  changes the size and provides mmu_gather::page_size to tlb_flush().
> 
> Ah, you add this later in the series. I think Nick reckoned we could get rid
> of this (the page_size field) eventually...

Right; let me fix that ordering..
