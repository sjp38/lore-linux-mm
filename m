Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 19E816B025E
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 05:57:55 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id e123so20176473oig.7
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 02:57:55 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w3si4570033oib.298.2017.10.10.02.57.53
        for <linux-mm@kvack.org>;
        Tue, 10 Oct 2017 02:57:53 -0700 (PDT)
Date: Tue, 10 Oct 2017 10:56:19 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH v2 1/3] kcov: support comparison operands collection
Message-ID: <20171010095618.GF27659@leverpostej>
References: <20171009150521.82775-1-glider@google.com>
 <20171009154610.GA22534@leverpostej>
 <CACT4Y+Y_79MQVHg--92AJFk3_9XoLgaM2zF3zK5ErfnH-zNcPw@mail.gmail.com>
 <20171009183734.GA7784@leverpostej>
 <CACT4Y+apUD89-neN7GUsbdZ9a1hMgRPQk-h4dhC9iDf+_6Kh=w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+apUD89-neN7GUsbdZ9a1hMgRPQk-h4dhC9iDf+_6Kh=w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Popov <alex.popov@linux.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, andreyknvl <andreyknvl@google.com>, Kees Cook <keescook@chromium.org>, Vegard Nossum <vegard.nossum@oracle.com>, syzkaller <syzkaller@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Oct 09, 2017 at 08:46:18PM +0200, 'Dmitry Vyukov' via syzkaller wrote:
> On Mon, Oct 9, 2017 at 8:37 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> > On Mon, Oct 09, 2017 at 08:15:10PM +0200, 'Dmitry Vyukov' via syzkaller wrote:
> >> On Mon, Oct 9, 2017 at 5:46 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> >> > On Mon, Oct 09, 2017 at 05:05:19PM +0200, Alexander Potapenko wrote:
> >
> >> > ... I note that a few places in the kernel use a 128-bit type. Are
> >> > 128-bit comparisons not instrumented?
> >>
> >> Yes, they are not instrumented.
> >> How many are there? Can you give some examples?
> >
> > From a quick scan, it doesn't looks like there are currently any
> > comparisons.
> >
> > It's used as a data type in a few places under arm64:
> >
> > arch/arm64/include/asm/checksum.h:      __uint128_t tmp;
> > arch/arm64/include/asm/checksum.h:      tmp = *(const __uint128_t *)iph;
> > arch/arm64/include/asm/fpsimd.h:                        __uint128_t vregs[32];
> > arch/arm64/include/uapi/asm/ptrace.h:   __uint128_t     vregs[32];
> > arch/arm64/include/uapi/asm/sigcontext.h:       __uint128_t vregs[32];
> > arch/arm64/kernel/signal32.c:   __uint128_t     raw;
> > arch/arm64/kvm/guest.c: __uint128_t tmp;
> 
> Then I think we just continue ignoring them for now :)
> In the future we can extend kcov to trace 128-bits values. We will
> need to add a special flag and write 2 consecutive entries for them.
> Or something along these lines.

Just wanted to make sure that we weren't backing ourselves into a corner
w.r.t. ABI; that sounds fine to me.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
