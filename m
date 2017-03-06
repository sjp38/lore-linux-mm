Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3AD0D6B0390
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 11:04:16 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 67so202473002pfg.0
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 08:04:16 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w63si19164468pgb.118.2017.03.06.08.04.15
        for <linux-mm@kvack.org>;
        Mon, 06 Mar 2017 08:04:15 -0800 (PST)
Date: Mon, 6 Mar 2017 16:04:03 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH] x86, kasan: add KASAN checks to atomic operations
Message-ID: <20170306160403.GB18519@leverpostej>
References: <20170306124254.77615-1-dvyukov@google.com>
 <CACT4Y+YmpTMdJca-rE2nXR-qa=wn_bCqQXaRghtg1uC65-pKyA@mail.gmail.com>
 <20170306125851.GL6500@twins.programming.kicks-ass.net>
 <20170306130107.GK6536@twins.programming.kicks-ass.net>
 <CACT4Y+ZDxk2CkaGaqVJfrzoBf4ZXDZ2L8vaAnLOjuY0yx85jgA@mail.gmail.com>
 <20170306152013.GN6500@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170306152013.GN6500@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, Will Deacon <will.deacon@arm.com>

On Mon, Mar 06, 2017 at 04:20:13PM +0100, Peter Zijlstra wrote:
> On Mon, Mar 06, 2017 at 03:24:23PM +0100, Dmitry Vyukov wrote:
> > We could also provide a parallel implementation of atomic ops based on
> > the new compiler builtins (__atomic_load_n and friends):
> > https://gcc.gnu.org/onlinedocs/gcc/_005f_005fatomic-Builtins.html
> > and enable it under KSAN. The nice thing about it is that it will
> > automatically support arm64 and KMSAN and KTSAN.
> > But it's more work.
> 
> There's a summary out there somewhere, I think Will knows, that explain
> how the C/C++ memory model and the Linux Kernel Memory model differ and
> how its going to be 'interesting' to make using the C/C++ builtin crud
> with the kernel 'correct.

Trivially, The C++ model doesn't feature I/O ordering [1]...

Otherwise Will pointed out a few details in [2].

Thanks,
Mark.

[1] https://lwn.net/Articles/698014/
[2] http://lwn.net/Articles/691295/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
