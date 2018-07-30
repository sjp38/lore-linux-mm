Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id A82DC6B0003
	for <linux-mm@kvack.org>; Mon, 30 Jul 2018 08:57:15 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id 13-v6so10837235oiq.1
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 05:57:15 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k189-v6si7638331oib.416.2018.07.30.05.57.11
        for <linux-mm@kvack.org>;
        Mon, 30 Jul 2018 05:57:11 -0700 (PDT)
Date: Mon, 30 Jul 2018 13:57:05 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [llvmlinux] clang fails on linux-next since commit 8bf705d13039
Message-ID: <20180730125705.wmyo3qqj4ro32ner@lakrids.cambridge.arm.com>
References: <CA+icZUVQZtvLg6XGwnS-4Zgv+tkCGWw5Ue8_585H_xNOofX76Q@mail.gmail.com>
 <20180730091934.omn2vj6eyh6kaecs@lakrids.cambridge.arm.com>
 <CA+icZUUicAr5hBB9oGtuLhygP4pf39YV9hhrg7GpJQUibZu=ig@mail.gmail.com>
 <20180730094622.av7wlyrkl3rn37mp@lakrids.cambridge.arm.com>
 <CA+icZUVEYs0Y+vdwB9o8bQf3QiOGJ_vZKnD3LGXVeAsok95S6w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+icZUVEYs0Y+vdwB9o8bQf3QiOGJ_vZKnD3LGXVeAsok95S6w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sedat Dilek <sedat.dilek@gmail.com>
Cc: Matthias Kaehlcke <mka@chromium.org>, Dmitry Vyukov <dvyukov@google.com>, Greg Hackmann <ghackmann@google.com>, Luis Lozano <llozano@google.com>, Michael Davidson <md@google.com>, Nick Desaulniers <ndesaulniers@google.com>, Paul Lawrence <paullawrence@google.com>, Sami Tolvanen <samitolvanen@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Ingo Molnar <mingo@kernel.org>, linux-mm@kvack.org, llvmlinux@lists.linuxfoundation.org, sil2review@lists.osadl.org, Jan Beulich <JBeulich@suse.com>, Peter Zijlstra <peterz@infradead.org>, Kees Cook <keescook@chromium.org>, Colin King <colin.king@canonical.com>

On Mon, Jul 30, 2018 at 02:28:42PM +0200, Sedat Dilek wrote:
> On Mon, Jul 30, 2018 at 11:46 AM, Mark Rutland <mark.rutland@arm.com> wrote:
> > On Mon, Jul 30, 2018 at 11:40:49AM +0200, Sedat Dilek wrote:
> >> What are your plans to have...
> >>
> >> 4d2b25f630c7 locking/atomics: Instrument cmpxchg_double*()
> >> f9881cc43b11 locking/atomics: Instrument xchg()
> >> df79ed2c0643 locking/atomics: Simplify cmpxchg() instrumentation
> >> 00d5551cc4ee locking/atomics/x86: Reduce arch_cmpxchg64*() instrumentation
> >>
> >> ...for example in Linux 4.18 or 4.17.y?
> >
> > I have no plans to have these backported.
> >
> 
> I guess this is 4.19 material?

Yes. the above 4 commits are all queued for v4.19.

Thanks,
Mark.
