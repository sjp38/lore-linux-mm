Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 23AA06B0006
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 07:39:55 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id u11-v6so11570698oif.22
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 04:39:55 -0700 (PDT)
Received: from gateway21.websitewelcome.com (gateway21.websitewelcome.com. [192.185.46.109])
        by mx.google.com with ESMTPS id h6-v6si8292073oib.203.2018.08.06.04.39.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Aug 2018 04:39:54 -0700 (PDT)
Received: from cm15.websitewelcome.com (cm15.websitewelcome.com [100.42.49.9])
	by gateway21.websitewelcome.com (Postfix) with ESMTP id C60B7400DC99A
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 06:39:53 -0500 (CDT)
References: <20180804220827.GA12559@embeddedor.com>
 <CACT4Y+arVJ4qt54LzKKoyh9+NKA+fjyCShKi82NanbovhK_mmQ@mail.gmail.com>
From: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Subject: Re: [PATCH] mm/kasan/kasan_init: use true and false for boolean
 values
Message-ID: <0413df4d-262d-fee8-f1a3-99ccf1d3a441@embeddedor.com>
Date: Mon, 6 Aug 2018 06:39:02 -0500
MIME-Version: 1.0
In-Reply-To: <CACT4Y+arVJ4qt54LzKKoyh9+NKA+fjyCShKi82NanbovhK_mmQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi Dmitry,

On 08/06/2018 04:04 AM, Dmitry Vyukov wrote:
> On Sun, Aug 5, 2018 at 12:08 AM, Gustavo A. R. Silva
> <gustavo@embeddedor.com> wrote:
>> Return statements in functions returning bool should use true or false
>> instead of an integer value.
>>
>> This code was detected with the help of Coccinelle.
>>
>> Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
> 
> Hi Gustavo,
> 
> I don't see this code in upstream tree. Is it against some other tree? Which?
> 

Yep. It's against linux-next.

Should I use [PATCH next] in the subject next time?

Thanks
--
Gustavo

> Thanks
> 
>> ---
>>  mm/kasan/kasan_init.c | 6 +++---
>>  1 file changed, 3 insertions(+), 3 deletions(-)
>>
>> diff --git a/mm/kasan/kasan_init.c b/mm/kasan/kasan_init.c
>> index 7a2a2f1..c742dc5 100644
>> --- a/mm/kasan/kasan_init.c
>> +++ b/mm/kasan/kasan_init.c
>> @@ -42,7 +42,7 @@ static inline bool kasan_p4d_table(pgd_t pgd)
>>  #else
>>  static inline bool kasan_p4d_table(pgd_t pgd)
>>  {
>> -       return 0;
>> +       return false;
>>  }
>>  #endif
>>  #if CONFIG_PGTABLE_LEVELS > 3
>> @@ -54,7 +54,7 @@ static inline bool kasan_pud_table(p4d_t p4d)
>>  #else
>>  static inline bool kasan_pud_table(p4d_t p4d)
>>  {
>> -       return 0;
>> +       return false;
>>  }
>>  #endif
>>  #if CONFIG_PGTABLE_LEVELS > 2
>> @@ -66,7 +66,7 @@ static inline bool kasan_pmd_table(pud_t pud)
>>  #else
>>  static inline bool kasan_pmd_table(pud_t pud)
>>  {
>> -       return 0;
>> +       return false;
>>  }
>>  #endif
>>  pte_t kasan_zero_pte[PTRS_PER_PTE] __page_aligned_bss;
>> --
>> 2.7.4
