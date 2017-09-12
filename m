Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 12E1A6B0253
	for <linux-mm@kvack.org>; Tue, 12 Sep 2017 13:42:21 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id q7so15264787ioi.3
        for <linux-mm@kvack.org>; Tue, 12 Sep 2017 10:42:21 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m202sor4549513ita.66.2017.09.12.10.42.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Sep 2017 10:42:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+bRVdvgFkkWxAZm0dv5vTQat=OhGN5cU+nAVAHA-AndfA@mail.gmail.com>
References: <cover.1504109849.git.dvyukov@google.com> <663c2a30de845dd13cf3cf64c3dfd437295d5ce2.1504109849.git.dvyukov@google.com>
 <20170830182357.GD32493@leverpostej> <CACT4Y+bRVdvgFkkWxAZm0dv5vTQat=OhGN5cU+nAVAHA-AndfA@mail.gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 12 Sep 2017 19:41:58 +0200
Message-ID: <CACT4Y+a85z12FdjuGTPzeJXYdYhQiNOMjykO2e0PwXEkqJUOag@mail.gmail.com>
Subject: Re: [PATCH 1/3] kcov: support comparison operands collection
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Victor Chibotaru <tchibo@google.com>, Alexander Popov <alex.popov@linux.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Kees Cook <keescook@chromium.org>, Vegard Nossum <vegard.nossum@oracle.com>, Quentin Casasnovas <quentin.casasnovas@oracle.com>, syzkaller <syzkaller@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, Aug 30, 2017 at 9:08 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Wed, Aug 30, 2017 at 8:23 PM, Mark Rutland <mark.rutland@arm.com> wrote:
>> Hi,
>>
>> On Wed, Aug 30, 2017 at 06:23:29PM +0200, Dmitry Vyukov wrote:
>>> From: Victor Chibotaru <tchibo@google.com>
>>>
>>> Enables kcov to collect comparison operands from instrumented code.
>>> This is done by using Clang's -fsanitize=trace-cmp instrumentation
>>> (currently not available for GCC).
>>
>> What's needed to build the kernel with Clang these days?
>>
>> I was under the impression that it still wasn't possible to build arm64
>> with clang due to a number of missing features (e.g. the %a assembler
>> output template).
>>
>>> The comparison operands help a lot in fuzz testing. E.g. they are
>>> used in Syzkaller to cover the interiors of conditional statements
>>> with way less attempts and thus make previously unreachable code
>>> reachable.
>>>
>>> To allow separate collection of coverage and comparison operands two
>>> different work modes are implemented. Mode selection is now done via
>>> a KCOV_ENABLE ioctl call with corresponding argument value.
>>>
>>> Signed-off-by: Victor Chibotaru <tchibo@google.com>
>>> Cc: Andrew Morton <akpm@linux-foundation.org>
>>> Cc: Mark Rutland <mark.rutland@arm.com>
>>> Cc: Alexander Popov <alex.popov@linux.com>
>>> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
>>> Cc: Kees Cook <keescook@chromium.org>
>>> Cc: Vegard Nossum <vegard.nossum@oracle.com>
>>> Cc: Quentin Casasnovas <quentin.casasnovas@oracle.com>
>>> Cc: syzkaller@googlegroups.com
>>> Cc: linux-mm@kvack.org
>>> Cc: linux-kernel@vger.kernel.org
>>> ---
>>> Clang instrumentation:
>>> https://clang.llvm.org/docs/SanitizerCoverage.html#tracing-data-flow
>>
>> How stable is this?
>>
>> The comment at the end says "This interface is a subject to change."
>
>
> The intention is that this is not subject to change anymore (since we
> are using it in kernel).
> I've mailed change to docs: https://reviews.llvm.org/D37303
>
> FWIW, there is patch in flight that adds this instrumentation to gcc:
> https://groups.google.com/forum/#!topic/syzkaller/CSLynn6nI-A
> It seems to be stalled on review phase, though.


Good news is that this is submitted to gcc in 251801.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
