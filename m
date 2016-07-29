Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 938966B0253
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 15:10:34 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id pp5so117980474pac.3
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 12:10:34 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 77si19683716pft.11.2016.07.29.12.10.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jul 2016 12:10:33 -0700 (PDT)
Subject: Re: kernel BUG at mm/mempolicy.c:1699!
References: <579B991C.9050809@oracle.com>
 <CACT4Y+a9=LJjaXgkp=0Dm+ftDbYQchqrzm7P9cM6ksRdHCnw-w@mail.gmail.com>
From: Vegard Nossum <vegard.nossum@oracle.com>
Message-ID: <579BAA1F.6000704@oracle.com>
Date: Fri, 29 Jul 2016 21:10:23 +0200
MIME-Version: 1.0
In-Reply-To: <CACT4Y+a9=LJjaXgkp=0Dm+ftDbYQchqrzm7P9cM6ksRdHCnw-w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On 07/29/2016 08:05 PM, Dmitry Vyukov wrote:
> On Fri, Jul 29, 2016 at 7:57 PM, Vegard Nossum <vegard.nossum@oracle.com> wrote:
>> ------------[ cut here ]------------
>> kernel BUG at mm/mempolicy.c:1699!
[...]
>> In particular, it's interesting that the kernel/exit.c line is
>>
>>      mpol_put(tsk->mempolicy);
>>
>> and alloc_pages_current() does (potentially):
>>
>>      pol = get_task_policy(current);.
>>
>> The bug seems very new or very rare or both.
>
> This is https://github.com/google/kasan/issues/35
> It is introduced with stackdepot.

Ah, cool.

Would it be enough to set __GFP_THISNODE in depot_save_stack() so it
uses &default_policy instead of current->mempolicy?


Vegard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
