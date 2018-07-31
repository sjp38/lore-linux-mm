Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id CE0B86B0007
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 03:24:11 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id u14-v6so1569971lfu.13
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 00:24:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y7-v6sor2980518ljj.104.2018.07.31.00.24.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Jul 2018 00:24:10 -0700 (PDT)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
In-Reply-To: <CAKwvOdmjD2fvZjZzkehB7ULG06z6Nqs5PjaoEzmyr51wBKQL+w@mail.gmail.com>
References: <CA+icZUVQZtvLg6XGwnS-4Zgv+tkCGWw5Ue8_585H_xNOofX76Q@mail.gmail.com>
 <20180730091934.omn2vj6eyh6kaecs@lakrids.cambridge.arm.com>
 <CA+icZUUicAr5hBB9oGtuLhygP4pf39YV9hhrg7GpJQUibZu=ig@mail.gmail.com>
 <20180730094622.av7wlyrkl3rn37mp@lakrids.cambridge.arm.com> <CAKwvOdmjD2fvZjZzkehB7ULG06z6Nqs5PjaoEzmyr51wBKQL+w@mail.gmail.com>
From: Sedat Dilek <sedat.dilek@gmail.com>
Date: Tue, 31 Jul 2018 09:24:09 +0200
Message-ID: <CA+icZUV7XMdo22E3NLwaR=YeL-Cqz7MXWKhu3zq0XZeCqHCH9g@mail.gmail.com>
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

The commit in Linus upstream tree is...

b06ed71a624b locking/atomic, asm-generic: Add asm-generic/atomic-instrumented.h

sdi@iniza:~/src/linux-kernel/linux$ git describe  --contains b06ed71a624b
v4.17-rc1~180^2~9

...so backporting makes sense for linux-stable-4.17.y?

- sed@ -
