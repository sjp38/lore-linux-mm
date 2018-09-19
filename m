Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id E9EE18E0001
	for <linux-mm@kvack.org>; Wed, 19 Sep 2018 09:13:03 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i68-v6so2815862pfb.9
        for <linux-mm@kvack.org>; Wed, 19 Sep 2018 06:13:03 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 22-v6si22039922pfb.215.2018.09.19.06.13.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 19 Sep 2018 06:13:01 -0700 (PDT)
Date: Wed, 19 Sep 2018 15:12:54 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC][PATCH 01/11] asm-generic/tlb: Provide a comment
Message-ID: <20180919131254.GI24124@hirez.programming.kicks-ass.net>
References: <20180913092110.817204997@infradead.org>
 <20180913092811.894806629@infradead.org>
 <20180914164857.GG6236@arm.com>
 <20180919115158.GD24124@hirez.programming.kicks-ass.net>
 <20180919122328.GB22723@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180919122328.GB22723@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, npiggin@gmail.com, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux@armlinux.org.uk, heiko.carstens@de.ibm.com

On Wed, Sep 19, 2018 at 01:23:29PM +0100, Will Deacon wrote:

> > > > + *    which (when !need_flush_all; fullmm will have start = end = ~0UL) provides
> > > > + *    the range that needs to be flushed to cover the pages to be freed.
> > > 
> > > I don't understand the mention of need_flush_all here -- I didn't think it
> > > was used by the core code at all.
> > 
> > The core does indeed not use that flag; but if the architecture set
> > that, the range is still ignored.
> > 
> > Can you suggest clearer wording?
> 
> The range is only ignored if the default tlb_flush() implementation is used
> though, right? Since this text is about the fields that tlb_flush() can use,
> I think we can just delete the part in brackets.

Well, any architecture that actually uses need_flush_all will obviously
require a tlb_flush implementation that looks at it.

But OK, I'll remove the note.
