Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id BF74C6B038E
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 10:20:14 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id w185so79889715ita.5
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 07:20:14 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id q62si11148618itq.27.2017.03.06.07.20.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 07:20:13 -0800 (PST)
Date: Mon, 6 Mar 2017 16:20:13 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] x86, kasan: add KASAN checks to atomic operations
Message-ID: <20170306152013.GN6500@twins.programming.kicks-ass.net>
References: <20170306124254.77615-1-dvyukov@google.com>
 <CACT4Y+YmpTMdJca-rE2nXR-qa=wn_bCqQXaRghtg1uC65-pKyA@mail.gmail.com>
 <20170306125851.GL6500@twins.programming.kicks-ass.net>
 <20170306130107.GK6536@twins.programming.kicks-ass.net>
 <CACT4Y+ZDxk2CkaGaqVJfrzoBf4ZXDZ2L8vaAnLOjuY0yx85jgA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+ZDxk2CkaGaqVJfrzoBf4ZXDZ2L8vaAnLOjuY0yx85jgA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Will Deacon <will.deacon@arm.com>

On Mon, Mar 06, 2017 at 03:24:23PM +0100, Dmitry Vyukov wrote:
> We could also provide a parallel implementation of atomic ops based on
> the new compiler builtins (__atomic_load_n and friends):
> https://gcc.gnu.org/onlinedocs/gcc/_005f_005fatomic-Builtins.html
> and enable it under KSAN. The nice thing about it is that it will
> automatically support arm64 and KMSAN and KTSAN.
> But it's more work.

There's a summary out there somewhere, I think Will knows, that explain
how the C/C++ memory model and the Linux Kernel Memory model differ and
how its going to be 'interesting' to make using the C/C++ builtin crud
with the kernel 'correct.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
