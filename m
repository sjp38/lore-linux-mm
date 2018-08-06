Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id D749F6B026B
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 08:05:41 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id d22-v6so8548435pfn.3
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 05:05:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m14-v6sor1561127pfi.25.2018.08.06.05.05.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Aug 2018 05:05:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0413df4d-262d-fee8-f1a3-99ccf1d3a441@embeddedor.com>
References: <20180804220827.GA12559@embeddedor.com> <CACT4Y+arVJ4qt54LzKKoyh9+NKA+fjyCShKi82NanbovhK_mmQ@mail.gmail.com>
 <0413df4d-262d-fee8-f1a3-99ccf1d3a441@embeddedor.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 6 Aug 2018 14:05:19 +0200
Message-ID: <CACT4Y+YDD2M4Z1XodDxOm-SQszGhMvS+7Tzuiq2FKCG8JK2uLA@mail.gmail.com>
Subject: Re: [PATCH] mm/kasan/kasan_init: use true and false for boolean values
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Aug 6, 2018 at 1:39 PM, Gustavo A. R. Silva
<gustavo@embeddedor.com> wrote:
> Hi Dmitry,
>
> On 08/06/2018 04:04 AM, Dmitry Vyukov wrote:
>> On Sun, Aug 5, 2018 at 12:08 AM, Gustavo A. R. Silva
>> <gustavo@embeddedor.com> wrote:
>>> Return statements in functions returning bool should use true or false
>>> instead of an integer value.
>>>
>>> This code was detected with the help of Coccinelle.
>>>
>>> Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
>>
>> Hi Gustavo,
>>
>> I don't see this code in upstream tree. Is it against some other tree? Which?
>>
>
> Yep. It's against linux-next.

See it now.

Acked-by: Dmitry Vyukov <dvyukov@google.com>

Thanks

> Should I use [PATCH next] in the subject next time?

I dunno. I just find this part of kernel development process strange
and confusing. Say, how should testing of kernel patches work? Usually
today base commit is just captured by review system.

> Thanks
> --
> Gustavo
>
>> Thanks
>>
>>> ---
>>>  mm/kasan/kasan_init.c | 6 +++---
>>>  1 file changed, 3 insertions(+), 3 deletions(-)
>>>
>>> diff --git a/mm/kasan/kasan_init.c b/mm/kasan/kasan_init.c
>>> index 7a2a2f1..c742dc5 100644
>>> --- a/mm/kasan/kasan_init.c
>>> +++ b/mm/kasan/kasan_init.c
>>> @@ -42,7 +42,7 @@ static inline bool kasan_p4d_table(pgd_t pgd)
>>>  #else
>>>  static inline bool kasan_p4d_table(pgd_t pgd)
>>>  {
>>> -       return 0;
>>> +       return false;
>>>  }
>>>  #endif
>>>  #if CONFIG_PGTABLE_LEVELS > 3
>>> @@ -54,7 +54,7 @@ static inline bool kasan_pud_table(p4d_t p4d)
>>>  #else
>>>  static inline bool kasan_pud_table(p4d_t p4d)
>>>  {
>>> -       return 0;
>>> +       return false;
>>>  }
>>>  #endif
>>>  #if CONFIG_PGTABLE_LEVELS > 2
>>> @@ -66,7 +66,7 @@ static inline bool kasan_pmd_table(pud_t pud)
>>>  #else
>>>  static inline bool kasan_pmd_table(pud_t pud)
>>>  {
>>> -       return 0;
>>> +       return false;
>>>  }
>>>  #endif
>>>  pte_t kasan_zero_pte[PTRS_PER_PTE] __page_aligned_bss;
>>> --
>>> 2.7.4
