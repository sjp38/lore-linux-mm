Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 430056B0390
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 03:52:38 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id w96so51099870wrb.13
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 00:52:38 -0700 (PDT)
Received: from mail-wr0-x243.google.com (mail-wr0-x243.google.com. [2a00:1450:400c:c0c::243])
        by mx.google.com with ESMTPS id d75si2468496wme.36.2017.03.28.00.52.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 00:52:36 -0700 (PDT)
Received: by mail-wr0-x243.google.com with SMTP id w43so17172372wrb.1
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 00:52:35 -0700 (PDT)
Date: Tue, 28 Mar 2017 09:52:32 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 2/3] asm-generic, x86: wrap atomic operations
Message-ID: <20170328075232.GA19590@gmail.com>
References: <cover.1489519233.git.dvyukov@google.com>
 <6bb1c71b87b300d04977c34f0cd8586363bc6170.1489519233.git.dvyukov@google.com>
 <20170324065203.GA5229@gmail.com>
 <CACT4Y+af=UPjL9EUCv9Z5SjHMRdOdUC1OOpq7LLKEHHKm8zysA@mail.gmail.com>
 <20170324105700.GB20282@gmail.com>
 <CACT4Y+YaFhVpu8-37=rOfOT1UN5K_bKMsMVQ+qiPZUWuSSERuw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+YaFhVpu8-37=rOfOT1UN5K_bKMsMVQ+qiPZUWuSSERuw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Peter Zijlstra <peterz@infradead.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>


* Dmitry Vyukov <dvyukov@google.com> wrote:

> On Fri, Mar 24, 2017 at 11:57 AM, Ingo Molnar <mingo@kernel.org> wrote:
> >
> > * Dmitry Vyukov <dvyukov@google.com> wrote:
> >
> >> > Are just utterly disgusting that turn perfectly readable code into an
> >> > unreadable, unmaintainable mess.
> >> >
> >> > You need to find some better, cleaner solution please, or convince me that no
> >> > such solution is possible. NAK for the time being.
> >>
> >> Well, I can just write all functions as is. Does it better confirm to kernel
> >> style?
> >
> > I think writing the prototypes out as-is, properly organized, beats any of these
> > macro based solutions.
> 
> You mean write out the prototypes, but use what for definitions? Macros again?

No, regular C code.

I don't see the point of generating all this code via CPP - it's certainly not 
making it more readable to me. I.e. this patch I commented on is a step backwards 
for readability.

I'd prefer repetition and a higher overall line count over complex CPP constructs.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
