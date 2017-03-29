Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8B7626B039F
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 09:37:59 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n11so7325964pfg.7
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 06:37:59 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s36si7521794pld.3.2017.03.29.06.37.58
        for <linux-mm@kvack.org>;
        Wed, 29 Mar 2017 06:37:58 -0700 (PDT)
Date: Wed, 29 Mar 2017 14:37:36 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH 5/8] x86: switch atomic.h to use atomic-instrumented.h
Message-ID: <20170329133736.GJ23442@leverpostej>
References: <cover.1490717337.git.dvyukov@google.com>
 <4d4bb87870e5d7b1a3c660c74a1cd474def20e74.1490717337.git.dvyukov@google.com>
 <CACT4Y+Z90ODfg7GBKo7sP=eTwJ0BAqg0PercVSCVzYYK4jdSGg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+Z90ODfg7GBKo7sP=eTwJ0BAqg0PercVSCVzYYK4jdSGg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Will Deacon <will.deacon@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Mar 28, 2017 at 06:25:07PM +0200, Dmitry Vyukov wrote:
> On Tue, Mar 28, 2017 at 6:15 PM, Dmitry Vyukov <dvyukov@google.com> wrote:

> >  #define __try_cmpxchg(ptr, pold, new, size)                            \
> >         __raw_try_cmpxchg((ptr), (pold), (new), (size), LOCK_PREFIX)
> >
> > -#define try_cmpxchg(ptr, pold, new)                                    \
> > +#define arch_try_cmpxchg(ptr, pold, new)                               \
> >         __try_cmpxchg((ptr), (pold), (new), sizeof(*(ptr)))
> 
> Is try_cmpxchg() a part of public interface like cmpxchg, or only a
> helper to implement atomic_try_cmpxchg()?
> If it's the latter than we don't need to wrap them.

De-facto, it's an x86-specific helper. It was added in commit:

    a9ebf306f52c756c ("locking/atomic: Introduce atomic_try_cmpxchg()")

... which did not add try_cmpxchg to any generic header.

If it was meant to be part of the public interface, we'd need a generic
definition.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
