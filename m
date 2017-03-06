Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8F8F56B0387
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 15:35:01 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id e129so35787282pfh.1
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 12:35:01 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id m1si20102074plb.1.2017.03.06.12.35.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 12:35:00 -0800 (PST)
Date: Mon, 6 Mar 2017 21:35:00 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] x86, kasan: add KASAN checks to atomic operations
Message-ID: <20170306203500.GR6500@twins.programming.kicks-ass.net>
References: <20170306124254.77615-1-dvyukov@google.com>
 <CACT4Y+YmpTMdJca-rE2nXR-qa=wn_bCqQXaRghtg1uC65-pKyA@mail.gmail.com>
 <20170306125851.GL6500@twins.programming.kicks-ass.net>
 <20170306130107.GK6536@twins.programming.kicks-ass.net>
 <CACT4Y+ZDxk2CkaGaqVJfrzoBf4ZXDZ2L8vaAnLOjuY0yx85jgA@mail.gmail.com>
 <20170306162018.GC18519@leverpostej>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170306162018.GC18519@leverpostej>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, will.deacon@arm.com

On Mon, Mar 06, 2017 at 04:20:18PM +0000, Mark Rutland wrote:
> > >> So the problem is doing load/stores from asm bits, and GCC
> > >> (traditionally) doesn't try and interpret APP asm bits.
> > >>
> > >> However, could we not write a GCC plugin that does exactly that?
> > >> Something that interprets the APP asm bits and generates these KASAN
> > >> bits that go with it?

> I don't think there's much you'll be able to do within the compiler,
> assuming you mean to derive this from the asm block inputs and outputs.

Nah, I was thinking about a full asm interpreter.

> Those can hide address-generation (e.g. with per-cpu stuff), which the
> compiler may erroneously be detected as racing.
> 
> Those may also take fake inputs (e.g. the sp input to arm64's
> __my_cpu_offset()) which may confuse matters.
> 
> Parsing the assembly itself will be *extremely* painful due to the way
> that's set up for run-time patching.

Argh, yah, completely forgot about all that alternative and similar
nonsense :/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
