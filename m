Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id DE9236B0279
	for <linux-mm@kvack.org>; Fri, 26 May 2017 15:29:18 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id v80so16812635oie.10
        for <linux-mm@kvack.org>; Fri, 26 May 2017 12:29:18 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h17sor350690otd.23.2017.05.26.12.29.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 May 2017 12:29:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170329133736.GJ23442@leverpostej>
References: <cover.1490717337.git.dvyukov@google.com> <4d4bb87870e5d7b1a3c660c74a1cd474def20e74.1490717337.git.dvyukov@google.com>
 <CACT4Y+Z90ODfg7GBKo7sP=eTwJ0BAqg0PercVSCVzYYK4jdSGg@mail.gmail.com> <20170329133736.GJ23442@leverpostej>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 26 May 2017 21:28:56 +0200
Message-ID: <CACT4Y+ZXTd1o_i7hvnjidHKaVzKVp+_EnP0q=hp+fqoj34XQ-Q@mail.gmail.com>
Subject: Re: [PATCH 5/8] x86: switch atomic.h to use atomic-instrumented.h
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Will Deacon <will.deacon@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Mar 29, 2017 at 3:37 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> On Tue, Mar 28, 2017 at 06:25:07PM +0200, Dmitry Vyukov wrote:
>> On Tue, Mar 28, 2017 at 6:15 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
>
>> >  #define __try_cmpxchg(ptr, pold, new, size)                            \
>> >         __raw_try_cmpxchg((ptr), (pold), (new), (size), LOCK_PREFIX)
>> >
>> > -#define try_cmpxchg(ptr, pold, new)                                    \
>> > +#define arch_try_cmpxchg(ptr, pold, new)                               \
>> >         __try_cmpxchg((ptr), (pold), (new), sizeof(*(ptr)))
>>
>> Is try_cmpxchg() a part of public interface like cmpxchg, or only a
>> helper to implement atomic_try_cmpxchg()?
>> If it's the latter than we don't need to wrap them.
>
> De-facto, it's an x86-specific helper. It was added in commit:
>
>     a9ebf306f52c756c ("locking/atomic: Introduce atomic_try_cmpxchg()")
>
> ... which did not add try_cmpxchg to any generic header.
>
> If it was meant to be part of the public interface, we'd need a generic
> definition.

Fixed in v2:
https://groups.google.com/forum/#!topic/kasan-dev/3PoGcuMku-w

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
