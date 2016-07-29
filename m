Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6925A6B0260
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 15:16:50 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id p85so40644931lfg.3
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 12:16:50 -0700 (PDT)
Received: from mail-lf0-x231.google.com (mail-lf0-x231.google.com. [2a00:1450:4010:c07::231])
        by mx.google.com with ESMTPS id g14si9507294ljg.42.2016.07.29.12.16.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jul 2016 12:16:48 -0700 (PDT)
Received: by mail-lf0-x231.google.com with SMTP id f93so77736742lfi.2
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 12:16:48 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <579BAA1F.6000704@oracle.com>
References: <579B991C.9050809@oracle.com> <CACT4Y+a9=LJjaXgkp=0Dm+ftDbYQchqrzm7P9cM6ksRdHCnw-w@mail.gmail.com>
 <579BAA1F.6000704@oracle.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 29 Jul 2016 21:16:29 +0200
Message-ID: <CACT4Y+aZLFP47uOvxZgXH0PHs=oipa_zO6eipRxnKuw82Y2Kpg@mail.gmail.com>
Subject: Re: kernel BUG at mm/mempolicy.c:1699!
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vegard Nossum <vegard.nossum@oracle.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Fri, Jul 29, 2016 at 9:10 PM, Vegard Nossum <vegard.nossum@oracle.com> wrote:
> On 07/29/2016 08:05 PM, Dmitry Vyukov wrote:
>>
>> On Fri, Jul 29, 2016 at 7:57 PM, Vegard Nossum <vegard.nossum@oracle.com>
>> wrote:
>>>
>>> ------------[ cut here ]------------
>>> kernel BUG at mm/mempolicy.c:1699!
>
> [...]
>>>
>>> In particular, it's interesting that the kernel/exit.c line is
>>>
>>>      mpol_put(tsk->mempolicy);
>>>
>>> and alloc_pages_current() does (potentially):
>>>
>>>      pol = get_task_policy(current);.
>>>
>>> The bug seems very new or very rare or both.
>>
>>
>> This is https://github.com/google/kasan/issues/35
>> It is introduced with stackdepot.
>
>
> Ah, cool.
>
> Would it be enough to set __GFP_THISNODE in depot_save_stack() so it
> uses &default_policy instead of current->mempolicy?

I don't have deep understanding of that code. But looks at the code,
using &default_policy should help.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
