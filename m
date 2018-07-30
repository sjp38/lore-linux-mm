Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 32C136B0006
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 12:36:03 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 31-v6so9363134pld.6
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 09:36:03 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o1-v6sor3338939pfk.89.2018.07.30.09.36.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Jul 2018 09:36:00 -0700 (PDT)
MIME-Version: 1.0
References: <CA+icZUVQZtvLg6XGwnS-4Zgv+tkCGWw5Ue8_585H_xNOofX76Q@mail.gmail.com>
 <20180730091934.omn2vj6eyh6kaecs@lakrids.cambridge.arm.com>
 <CA+icZUUicAr5hBB9oGtuLhygP4pf39YV9hhrg7GpJQUibZu=ig@mail.gmail.com> <20180730094622.av7wlyrkl3rn37mp@lakrids.cambridge.arm.com>
In-Reply-To: <20180730094622.av7wlyrkl3rn37mp@lakrids.cambridge.arm.com>
From: Nick Desaulniers <ndesaulniers@google.com>
Date: Mon, 30 Jul 2018 09:35:48 -0700
Message-ID: <CAKwvOdmjD2fvZjZzkehB7ULG06z6Nqs5PjaoEzmyr51wBKQL+w@mail.gmail.com>
Subject: Re: [llvmlinux] clang fails on linux-next since commit 8bf705d13039
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: sedat.dilek@gmail.com, Matthias Kaehlcke <mka@chromium.org>, Dmitry Vyukov <dvyukov@google.com>, Greg Hackmann <ghackmann@google.com>, Luis Lozano <llozano@google.com>, Michael Davidson <md@google.com>, Paul Lawrence <paullawrence@google.com>, Sami Tolvanen <samitolvanen@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Ingo Molnar <mingo@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, llvmlinux@lists.linuxfoundation.org, sil2review@lists.osadl.org, JBeulich@suse.com, Peter Zijlstra <peterz@infradead.org>, Kees Cook <keescook@chromium.org>, Colin Ian King <colin.king@canonical.com>

On Mon, Jul 30, 2018 at 2:46 AM Mark Rutland <mark.rutland@arm.com> wrote:
>
> On Mon, Jul 30, 2018 at 11:40:49AM +0200, Sedat Dilek wrote:
> > What are your plans to have...
> >
> > 4d2b25f630c7 locking/atomics: Instrument cmpxchg_double*()
> > f9881cc43b11 locking/atomics: Instrument xchg()
> > df79ed2c0643 locking/atomics: Simplify cmpxchg() instrumentation
> > 00d5551cc4ee locking/atomics/x86: Reduce arch_cmpxchg64*() instrumentation
> >
> > ...for example in Linux 4.18 or 4.17.y?
>
> I have no plans to have these backported.

If they help us compile with clang, we'll backport to 4.17, 4.14, 4.9,
and 4.4 stable.  From
https://github.com/ClangBuiltLinux/linux/issues/3#issuecomment-408839428,
it sounds like that is the case.

-- 
Thanks,
~Nick Desaulniers
