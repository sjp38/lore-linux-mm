Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 19B936B000A
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 12:40:12 -0400 (EDT)
Received: by mail-lj1-f197.google.com with SMTP id z24-v6so2820661lji.16
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 09:40:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d192-v6sor1136550lfd.176.2018.07.30.09.40.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Jul 2018 09:40:08 -0700 (PDT)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
In-Reply-To: <CAKwvOdmjD2fvZjZzkehB7ULG06z6Nqs5PjaoEzmyr51wBKQL+w@mail.gmail.com>
References: <CA+icZUVQZtvLg6XGwnS-4Zgv+tkCGWw5Ue8_585H_xNOofX76Q@mail.gmail.com>
 <20180730091934.omn2vj6eyh6kaecs@lakrids.cambridge.arm.com>
 <CA+icZUUicAr5hBB9oGtuLhygP4pf39YV9hhrg7GpJQUibZu=ig@mail.gmail.com>
 <20180730094622.av7wlyrkl3rn37mp@lakrids.cambridge.arm.com> <CAKwvOdmjD2fvZjZzkehB7ULG06z6Nqs5PjaoEzmyr51wBKQL+w@mail.gmail.com>
From: Sedat Dilek <sedat.dilek@gmail.com>
Date: Mon, 30 Jul 2018 18:40:06 +0200
Message-ID: <CA+icZUUR+smEp439Z1TCfBA=_AL+DrNgRxP6i5gb9DqksEAXzg@mail.gmail.com>
Subject: Re: [llvmlinux] clang fails on linux-next since commit 8bf705d13039
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Desaulniers <ndesaulniers@google.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Matthias Kaehlcke <mka@chromium.org>, Dmitry Vyukov <dvyukov@google.com>, Greg Hackmann <ghackmann@google.com>, Luis Lozano <llozano@google.com>, Michael Davidson <md@google.com>, Paul Lawrence <paullawrence@google.com>, Sami Tolvanen <samitolvanen@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Ingo Molnar <mingo@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, llvmlinux@lists.linuxfoundation.org, sil2review@lists.osadl.org, JBeulich@suse.com, Peter Zijlstra <peterz@infradead.org>, Kees Cook <keescook@chromium.org>, Colin Ian King <colin.king@canonical.com>

On Mon, Jul 30, 2018 at 6:35 PM, Nick Desaulniers
<ndesaulniers@google.com> wrote:
> On Mon, Jul 30, 2018 at 2:46 AM Mark Rutland <mark.rutland@arm.com> wrote:
>>
>> On Mon, Jul 30, 2018 at 11:40:49AM +0200, Sedat Dilek wrote:
>> > What are your plans to have...
>> >
>> > 4d2b25f630c7 locking/atomics: Instrument cmpxchg_double*()
>> > f9881cc43b11 locking/atomics: Instrument xchg()
>> > df79ed2c0643 locking/atomics: Simplify cmpxchg() instrumentation
>> > 00d5551cc4ee locking/atomics/x86: Reduce arch_cmpxchg64*() instrumentation
>> >
>> > ...for example in Linux 4.18 or 4.17.y?
>>
>> I have no plans to have these backported.
>
> If they help us compile with clang, we'll backport to 4.17, 4.14, 4.9,
> and 4.4 stable.  From
> https://github.com/ClangBuiltLinux/linux/issues/3#issuecomment-408839428,
> it sounds like that is the case.
>

I am doing a CONFIG_HARDENED_USERCOPY=n build right now and see
tommorow if it boots on bare metal.

- sed@ -
