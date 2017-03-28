Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 76EB16B0397
	for <linux-mm@kvack.org>; Tue, 28 Mar 2017 12:30:02 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id 6so58494719vkn.10
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 09:30:02 -0700 (PDT)
Received: from mail-vk0-x233.google.com (mail-vk0-x233.google.com. [2607:f8b0:400c:c05::233])
        by mx.google.com with ESMTPS id i93si1846876uad.64.2017.03.28.09.30.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Mar 2017 09:30:01 -0700 (PDT)
Received: by mail-vk0-x233.google.com with SMTP id r69so94574484vke.2
        for <linux-mm@kvack.org>; Tue, 28 Mar 2017 09:30:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170328101532.GA13819@gmail.com>
References: <cover.1489519233.git.dvyukov@google.com> <6bb1c71b87b300d04977c34f0cd8586363bc6170.1489519233.git.dvyukov@google.com>
 <20170324065203.GA5229@gmail.com> <CACT4Y+af=UPjL9EUCv9Z5SjHMRdOdUC1OOpq7LLKEHHKm8zysA@mail.gmail.com>
 <20170324105700.GB20282@gmail.com> <CACT4Y+YaFhVpu8-37=rOfOT1UN5K_bKMsMVQ+qiPZUWuSSERuw@mail.gmail.com>
 <20170328075232.GA19590@gmail.com> <20170328092712.bk32k5iteqqm6pgh@hirez.programming.kicks-ass.net>
 <20170328095151.GC30567@gmail.com> <CACT4Y+Y0YGifJhw0sFpSYh=SapUv93M0QDwZFyP-9q1fnqWZug@mail.gmail.com>
 <20170328101532.GA13819@gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Tue, 28 Mar 2017 18:29:39 +0200
Message-ID: <CACT4Y+ZA51-WnVUUr2jXZCDxkrKA_RpQkMf58niiu5FvBrXZ4w@mail.gmail.com>
Subject: Re: [PATCH 2/3] asm-generic, x86: wrap atomic operations
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Mark Rutland <mark.rutland@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>

On Tue, Mar 28, 2017 at 12:15 PM, Ingo Molnar <mingo@kernel.org> wrote:
>
> * Dmitry Vyukov <dvyukov@google.com> wrote:
>
>> > So I'm not convinced that it's true in this case.
>> >
>> > Could we see the C version and compare? I could be wrong about it all.
>>
>> Here it is (without instrumentation):
>> https://gist.github.com/dvyukov/e33d580f701019e0cd99429054ff1f9a
>
> Could you please include the full patch so that it can be discussed via email and
> such?


Mailed the whole series.


>> Instrumentation will add for each function:
>>
>>  static __always_inline void atomic64_set(atomic64_t *v, long long i)
>>  {
>> +       kasan_check_write(v, sizeof(*v));
>>         arch_atomic64_set(v, i);
>>  }
>
> That in itself looks sensible and readable.
>
> Thanks,
>
>         Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
