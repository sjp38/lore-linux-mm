Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id B91CA6B03A2
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 06:15:37 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id f50so51604041wrf.7
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 03:15:37 -0700 (PDT)
Received: from mail-wr0-x242.google.com (mail-wr0-x242.google.com. [2a00:1450:400c:c0c::242])
        by mx.google.com with ESMTPS id z65si4158978wrc.101.2017.03.28.03.15.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 03:15:36 -0700 (PDT)
Received: by mail-wr0-x242.google.com with SMTP id u18so1712535wrc.0
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 03:15:36 -0700 (PDT)
Date: Tue, 28 Mar 2017 12:15:32 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 2/3] asm-generic, x86: wrap atomic operations
Message-ID: <20170328101532.GA13819@gmail.com>
References: <cover.1489519233.git.dvyukov@google.com>
 <6bb1c71b87b300d04977c34f0cd8586363bc6170.1489519233.git.dvyukov@google.com>
 <20170324065203.GA5229@gmail.com>
 <CACT4Y+af=UPjL9EUCv9Z5SjHMRdOdUC1OOpq7LLKEHHKm8zysA@mail.gmail.com>
 <20170324105700.GB20282@gmail.com>
 <CACT4Y+YaFhVpu8-37=rOfOT1UN5K_bKMsMVQ+qiPZUWuSSERuw@mail.gmail.com>
 <20170328075232.GA19590@gmail.com>
 <20170328092712.bk32k5iteqqm6pgh@hirez.programming.kicks-ass.net>
 <20170328095151.GC30567@gmail.com>
 <CACT4Y+Y0YGifJhw0sFpSYh=SapUv93M0QDwZFyP-9q1fnqWZug@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+Y0YGifJhw0sFpSYh=SapUv93M0QDwZFyP-9q1fnqWZug@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Mark Rutland <mark.rutland@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>


* Dmitry Vyukov <dvyukov@google.com> wrote:

> > So I'm not convinced that it's true in this case.
> >
> > Could we see the C version and compare? I could be wrong about it all.
> 
> Here it is (without instrumentation):
> https://gist.github.com/dvyukov/e33d580f701019e0cd99429054ff1f9a

Could you please include the full patch so that it can be discussed via email and 
such?

> Instrumentation will add for each function:
> 
>  static __always_inline void atomic64_set(atomic64_t *v, long long i)
>  {
> +       kasan_check_write(v, sizeof(*v));
>         arch_atomic64_set(v, i);
>  }

That in itself looks sensible and readable.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
