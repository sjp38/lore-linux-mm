Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id C73926B0390
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 11:57:01 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id v21so12359645pgo.22
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 08:57:01 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id n1si7800631pld.289.2017.03.29.08.57.00
        for <linux-mm@kvack.org>;
        Wed, 29 Mar 2017 08:57:01 -0700 (PDT)
Date: Wed, 29 Mar 2017 16:56:32 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH 7/8] asm-generic: add KASAN instrumentation to atomic
 operations
Message-ID: <20170329155631.GA26135@leverpostej>
References: <cover.1490717337.git.dvyukov@google.com>
 <b560d54e8be963f4155036a1f4b94d7f48b20af5.1490717337.git.dvyukov@google.com>
 <20170329140000.GK23442@leverpostej>
 <CACT4Y+ay7J4kdLG1i2Czop6H3pDKxpcRVxM0xoNiZ2pJ0emHQw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+ay7J4kdLG1i2Czop6H3pDKxpcRVxM0xoNiZ2pJ0emHQw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Will Deacon <will.deacon@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Mar 29, 2017 at 05:52:43PM +0200, Dmitry Vyukov wrote:
> On Wed, Mar 29, 2017 at 4:00 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> > On Tue, Mar 28, 2017 at 06:15:44PM +0200, Dmitry Vyukov wrote:
> >> KASAN uses compiler instrumentation to intercept all memory accesses.
> >> But it does not see memory accesses done in assembly code.
> >> One notable user of assembly code is atomic operations. Frequently,
> >> for example, an atomic reference decrement is the last access to an
> >> object and a good candidate for a racy use-after-free.
> >>
> >> Add manual KASAN checks to atomic operations.
> >>
> >> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
> >> Cc: Mark Rutland <mark.rutland@arm.com>
> >> Cc: Peter Zijlstra <peterz@infradead.org>
> >> Cc: Will Deacon <will.deacon@arm.com>,
> >> Cc: Andrew Morton <akpm@linux-foundation.org>,
> >> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
> >> Cc: Ingo Molnar <mingo@redhat.com>,
> >> Cc: kasan-dev@googlegroups.com
> >> Cc: linux-mm@kvack.org
> >> Cc: linux-kernel@vger.kernel.org
> >> Cc: x86@kernel.org
> >
> > FWIW, I think that structuring the file this way will make it easier to
> > add the {acquire,release,relaxed} variants (as arm64 will need),
> > so this looks good to me.
> >
> > As a heads-up, I wanted to have a go at that, but I wasn't able to apply
> > patch two onwards on v4.11-rc{3,4} or next-20170329. I was not able to
> > cleanly revert the instrumentation patches currently in next-20170329,
> > since other patches built atop of them.
> 
> I based it on git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git
> locking/core

Ah; I should have guessed. ;)

Thanks for the pointer!  I'll give that a go shortly.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
