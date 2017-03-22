Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id C35436B0344
	for <linux-mm@kvack.org>; Wed, 22 Mar 2017 08:48:39 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id x203so108345380oig.2
        for <linux-mm@kvack.org>; Wed, 22 Mar 2017 05:48:39 -0700 (PDT)
Received: from mail-ot0-x244.google.com (mail-ot0-x244.google.com. [2607:f8b0:4003:c0f::244])
        by mx.google.com with ESMTPS id q64si705315oig.0.2017.03.22.05.48.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Mar 2017 05:48:38 -0700 (PDT)
Received: by mail-ot0-x244.google.com with SMTP id i50so15995173otd.0
        for <linux-mm@kvack.org>; Wed, 22 Mar 2017 05:48:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACT4Y+bJOw_iMMkMw89oMqNsBCbqapXrS1Sk1uigjgB_7mnAgg@mail.gmail.com>
References: <cover.1489519233.git.dvyukov@google.com> <6bb1c71b87b300d04977c34f0cd8586363bc6170.1489519233.git.dvyukov@google.com>
 <20170320171718.GL31213@leverpostej> <956a8e10-e03f-a21c-99d9-8a75c2616e0a@virtuozzo.com>
 <20170321104139.GA22188@leverpostej> <CACT4Y+bNrh_a8mBth7ewHS-Fk=wgCky4=Uc89ePeuh5jrLvCQg@mail.gmail.com>
 <CAK8P3a3FqENx+tsg3cbbW4CQtpye7k8MedQqMZidxMCrBR8byg@mail.gmail.com>
 <CACT4Y+ZfWiDY27wehrg3wY1-_19JqEh1B8n7_xdf4u-rzDHFHw@mail.gmail.com>
 <CAK8P3a1o3ZwS2y9uoE9Cp70E1s-s5NyQ43zNzTjEiMXiH_tKng@mail.gmail.com> <CACT4Y+bJOw_iMMkMw89oMqNsBCbqapXrS1Sk1uigjgB_7mnAgg@mail.gmail.com>
From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 22 Mar 2017 13:48:37 +0100
Message-ID: <CAK8P3a1nheF5bWw67M0vpdo3F_O-ChQTgH6cgw_ATtYuLZumHw@mail.gmail.com>
Subject: Re: [PATCH 2/3] asm-generic, x86: wrap atomic operations
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Mar 22, 2017 at 1:14 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Wed, Mar 22, 2017 at 12:30 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>> On Wed, Mar 22, 2017 at 11:42 AM, Dmitry Vyukov <dvyukov@google.com> wrote:
>>> On Tue, Mar 21, 2017 at 10:20 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>>>> On Tue, Mar 21, 2017 at 7:06 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
>>>
>>> Initially I've tested with my stock gcc 4.8.4 (Ubuntu
>>> 4.8.4-2ubuntu1~14.04.3) and amusingly it works. But I can reproduce
>>> the bug with 7.0.1.
>>
>> It's probably because gcc-4.8 didn't support KASAN yet, so the added
>> check had no effect.
>
> I've tested without KASAN with both compilers.

Ah ok. I had not realized that this happened even without KASAN. I only saw this
problem in one out of hundreds of defconfig builds and assumed it was related
since this came from a kasan change.

      Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
