Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 52EA56B0333
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 08:46:22 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id d188so1378165vka.2
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 05:46:22 -0700 (PDT)
Received: from mail-vk0-x231.google.com (mail-vk0-x231.google.com. [2607:f8b0:400c:c05::231])
        by mx.google.com with ESMTPS id h72si871779vkd.25.2017.03.24.05.46.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 05:46:21 -0700 (PDT)
Received: by mail-vk0-x231.google.com with SMTP id r69so1444337vke.2
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 05:46:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170324105700.GB20282@gmail.com>
References: <cover.1489519233.git.dvyukov@google.com> <6bb1c71b87b300d04977c34f0cd8586363bc6170.1489519233.git.dvyukov@google.com>
 <20170324065203.GA5229@gmail.com> <CACT4Y+af=UPjL9EUCv9Z5SjHMRdOdUC1OOpq7LLKEHHKm8zysA@mail.gmail.com>
 <20170324105700.GB20282@gmail.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 24 Mar 2017 13:46:00 +0100
Message-ID: <CACT4Y+YaFhVpu8-37=rOfOT1UN5K_bKMsMVQ+qiPZUWuSSERuw@mail.gmail.com>
Subject: Re: [PATCH 2/3] asm-generic, x86: wrap atomic operations
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Mark Rutland <mark.rutland@arm.com>, Peter Zijlstra <peterz@infradead.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>

On Fri, Mar 24, 2017 at 11:57 AM, Ingo Molnar <mingo@kernel.org> wrote:
>
> * Dmitry Vyukov <dvyukov@google.com> wrote:
>
>> > Are just utterly disgusting that turn perfectly readable code into an
>> > unreadable, unmaintainable mess.
>> >
>> > You need to find some better, cleaner solution please, or convince me that no
>> > such solution is possible. NAK for the time being.
>>
>> Well, I can just write all functions as is. Does it better confirm to kernel
>> style?
>
> I think writing the prototypes out as-is, properly organized, beats any of these
> macro based solutions.

You mean write out the prototypes, but use what for definitions? Macros again?

>> [...] I've just looked at the x86 atomic.h and it uses macros for similar
>> purpose (ATOMIC_OP/ATOMIC_FETCH_OP), so I thought that must be idiomatic kernel
>> style...
>
> Mind fixing those too while at it?

I don't mind once I understand how exactly you want it to look.

> And please squash any bug fixes and re-send a clean series against latest upstream
> or so.
>
> Thanks,
>
>         Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
