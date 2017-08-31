Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3A1306B02C3
	for <linux-mm@kvack.org>; Thu, 31 Aug 2017 05:33:09 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id x184so248807oia.8
        for <linux-mm@kvack.org>; Thu, 31 Aug 2017 02:33:09 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k83si2814021oih.269.2017.08.31.02.33.07
        for <linux-mm@kvack.org>;
        Thu, 31 Aug 2017 02:33:08 -0700 (PDT)
Date: Thu, 31 Aug 2017 10:31:47 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH 1/3] kcov: support comparison operands collection
Message-ID: <20170831093146.GA15031@leverpostej>
References: <cover.1504109849.git.dvyukov@google.com>
 <663c2a30de845dd13cf3cf64c3dfd437295d5ce2.1504109849.git.dvyukov@google.com>
 <20170830182357.GD32493@leverpostej>
 <CACT4Y+bRVdvgFkkWxAZm0dv5vTQat=OhGN5cU+nAVAHA-AndfA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+bRVdvgFkkWxAZm0dv5vTQat=OhGN5cU+nAVAHA-AndfA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Victor Chibotaru <tchibo@google.com>, Alexander Popov <alex.popov@linux.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Kees Cook <keescook@chromium.org>, Vegard Nossum <vegard.nossum@oracle.com>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, syzkaller <syzkaller@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, Aug 30, 2017 at 09:08:43PM +0200, Dmitry Vyukov wrote:
> On Wed, Aug 30, 2017 at 8:23 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> > On Wed, Aug 30, 2017 at 06:23:29PM +0200, Dmitry Vyukov wrote:
> >> From: Victor Chibotaru <tchibo@google.com>
> >>
> >> Enables kcov to collect comparison operands from instrumented code.
> >> This is done by using Clang's -fsanitize=trace-cmp instrumentation
> >> (currently not available for GCC).

> >> Clang instrumentation:
> >> https://clang.llvm.org/docs/SanitizerCoverage.html#tracing-data-flow
> >
> > How stable is this?
> >
> > The comment at the end says "This interface is a subject to change."
> 
> The intention is that this is not subject to change anymore (since we
> are using it in kernel).
> I've mailed change to docs: https://reviews.llvm.org/D37303

Ok; thanks for confirming.

> FWIW, there is patch in flight that adds this instrumentation to gcc:
> https://groups.google.com/forum/#!topic/syzkaller/CSLynn6nI-A
> It seems to be stalled on review phase, though.

Let's hope it gets unblocked soon. :)

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
