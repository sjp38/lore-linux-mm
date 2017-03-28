Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id DB04F6B039F
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 05:27:21 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id 190so10235456itm.19
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 02:27:21 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id u124si2563947itd.111.2017.03.28.02.27.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 02:27:20 -0700 (PDT)
Date: Tue, 28 Mar 2017 11:27:12 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 2/3] asm-generic, x86: wrap atomic operations
Message-ID: <20170328092712.bk32k5iteqqm6pgh@hirez.programming.kicks-ass.net>
References: <cover.1489519233.git.dvyukov@google.com>
 <6bb1c71b87b300d04977c34f0cd8586363bc6170.1489519233.git.dvyukov@google.com>
 <20170324065203.GA5229@gmail.com>
 <CACT4Y+af=UPjL9EUCv9Z5SjHMRdOdUC1OOpq7LLKEHHKm8zysA@mail.gmail.com>
 <20170324105700.GB20282@gmail.com>
 <CACT4Y+YaFhVpu8-37=rOfOT1UN5K_bKMsMVQ+qiPZUWuSSERuw@mail.gmail.com>
 <20170328075232.GA19590@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170328075232.GA19590@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Dmitry Vyukov <dvyukov@google.com>, Mark Rutland <mark.rutland@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>

On Tue, Mar 28, 2017 at 09:52:32AM +0200, Ingo Molnar wrote:

> No, regular C code.
> 
> I don't see the point of generating all this code via CPP - it's certainly not 
> making it more readable to me. I.e. this patch I commented on is a step backwards 
> for readability.

Note that much of the atomic stuff we have today is all CPP already.

x86 is the exception because its 'weird', but most other archs are
almost pure CPP -- check Alpha for example, or asm-generic/atomic.h.

Also, look at linux/atomic.h, its a giant maze of CPP.

The CPP help us generate functions, reduces endless copy/paste (which
induces random differences -- read bugs) and construct variants
depending on the architecture input.

Yes, the CPP is a pain, but writing all that out explicitly is more of a
pain.



I've not yet looked too hard at these patches under consideration; and I
really wish we could get the compiler to do the right thing here, but
reducing the endless copy/paste that's otherwise the result of this, is
something I've found to be very valuable.

Not to mention that adding additional atomic ops got trivial (the set is
now near complete, so that's not much of an argument anymore -- but it
was, its what kept me sane sanitizing the atomic ops across all our 25+
architectures).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
