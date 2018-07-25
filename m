Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2BD4B6B0003
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 12:06:14 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id j189-v6so7758496oih.11
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 09:06:14 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s13-v6si9730775oih.381.2018.07.25.09.06.11
        for <linux-mm@kvack.org>;
        Wed, 25 Jul 2018 09:06:11 -0700 (PDT)
Date: Wed, 25 Jul 2018 17:06:10 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 02/10] mm: workingset: tell cache transitions from
 workingset thrashing
Message-ID: <20180725160610.GD6866@arm.com>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180712172942.10094-3-hannes@cmpxchg.org>
 <CAK8P3a3Nsmt54-ed_gWNev3CBS6_Sv5QGOw4G0sY4ZXOi1R4_Q@mail.gmail.com>
 <20180723152323.GA3699@cmpxchg.org>
 <CAK8P3a15K-TXYuFX-ZsJiroqA1GWX2XS4ioZSjcjJYgh1b_xSA@mail.gmail.com>
 <20180723162735.GA5980@cmpxchg.org>
 <20180724150448.GA25412@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180724150448.GA25412@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Peter Zijlstra <peterz@infradead.org>, Suren Baghdasaryan <surenb@google.com>, Mike Galbraith <efault@gmx.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, kernel-team@fb.com, Linux-MM <linux-mm@kvack.org>, Vinayak Menon <vinmenon@codeaurora.org>, Ingo Molnar <mingo@redhat.com>, Shakeel Butt <shakeelb@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Christopher Lameter <cl@linux.com>, Linux ARM <linux-arm-kernel@lists.infradead.org>

On Tue, Jul 24, 2018 at 04:04:48PM +0100, Will Deacon wrote:
> On Mon, Jul 23, 2018 at 12:27:35PM -0400, Johannes Weiner wrote:
> > On Mon, Jul 23, 2018 at 05:35:35PM +0200, Arnd Bergmann wrote:
> > > On Mon, Jul 23, 2018 at 5:23 PM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > > > diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
> > > > index 1b18b4722420..72c9b6778b0a 100644
> > > > --- a/arch/arm64/mm/init.c
> > > > +++ b/arch/arm64/mm/init.c
> > > > @@ -611,11 +611,13 @@ void __init mem_init(void)
> > > >         BUILD_BUG_ON(TASK_SIZE_32                       > TASK_SIZE_64);
> > > >  #endif
> > > >
> > > > +#ifndef CONFIG_SPARSEMEM_VMEMMAP
> > > >         /*
> > > 
> > > I tested it on two broken configurations, and found that you have
> > > a typo here, it should be 'ifdef', not 'ifndef'. With that change, it
> > > seems to build fine.
> > > 
> > > Tested-by: Arnd Bergmann <arnd@arndb.de>
> > 
> > Thanks for testing it, I don't have a cross-compile toolchain set up.
> > 
> > ---
> 
> Thanks Arnd, Johannes. I can pick this up for -rc7 via the arm64 tree,
> unless it's already queued elsewhere?

I've pushed this to the arm64 for-next/fixes branch heading for -rc7.

Will
