Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id BF8726B0003
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 08:28:45 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id k22-v6so2678758lji.0
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 05:28:45 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j21-v6sor2393201ljh.38.2018.07.30.05.28.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Jul 2018 05:28:43 -0700 (PDT)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
In-Reply-To: <20180730094622.av7wlyrkl3rn37mp@lakrids.cambridge.arm.com>
References: <CA+icZUVQZtvLg6XGwnS-4Zgv+tkCGWw5Ue8_585H_xNOofX76Q@mail.gmail.com>
 <20180730091934.omn2vj6eyh6kaecs@lakrids.cambridge.arm.com>
 <CA+icZUUicAr5hBB9oGtuLhygP4pf39YV9hhrg7GpJQUibZu=ig@mail.gmail.com> <20180730094622.av7wlyrkl3rn37mp@lakrids.cambridge.arm.com>
From: Sedat Dilek <sedat.dilek@gmail.com>
Date: Mon, 30 Jul 2018 14:28:42 +0200
Message-ID: <CA+icZUVEYs0Y+vdwB9o8bQf3QiOGJ_vZKnD3LGXVeAsok95S6w@mail.gmail.com>
Subject: Re: [llvmlinux] clang fails on linux-next since commit 8bf705d13039
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Matthias Kaehlcke <mka@chromium.org>, Dmitry Vyukov <dvyukov@google.com>, Greg Hackmann <ghackmann@google.com>, Luis Lozano <llozano@google.com>, Michael Davidson <md@google.com>, Nick Desaulniers <ndesaulniers@google.com>, Paul Lawrence <paullawrence@google.com>, Sami Tolvanen <samitolvanen@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Ingo Molnar <mingo@kernel.org>, linux-mm@kvack.org, llvmlinux@lists.linuxfoundation.org, sil2review@lists.osadl.org, Jan Beulich <JBeulich@suse.com>, Peter Zijlstra <peterz@infradead.org>, Kees Cook <keescook@chromium.org>, Colin King <colin.king@canonical.com>

On Mon, Jul 30, 2018 at 11:46 AM, Mark Rutland <mark.rutland@arm.com> wrote:
> On Mon, Jul 30, 2018 at 11:40:49AM +0200, Sedat Dilek wrote:
>> What are your plans to have...
>>
>> 4d2b25f630c7 locking/atomics: Instrument cmpxchg_double*()
>> f9881cc43b11 locking/atomics: Instrument xchg()
>> df79ed2c0643 locking/atomics: Simplify cmpxchg() instrumentation
>> 00d5551cc4ee locking/atomics/x86: Reduce arch_cmpxchg64*() instrumentation
>>
>> ...for example in Linux 4.18 or 4.17.y?
>
> I have no plans to have these backported.
>

I guess this is 4.19 material?

Not sure, if I will try a "backport" myself or wait for the fix in clang.

Thanks Mark.

Regards,
- Sedat -
