Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id DABF76B0394
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 09:18:55 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id g10so39813072wrg.5
        for <linux-mm@kvack.org>; Fri, 03 Mar 2017 06:18:55 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z88sor49277wrb.27.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 03 Mar 2017 06:18:54 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAAeHK+xOnrF9yeN-ph4Otv=SueZqndk+=XiVu-FRPs8RV5poaw@mail.gmail.com>
References: <20170302134851.101218-1-andreyknvl@google.com>
 <20170302134851.101218-6-andreyknvl@google.com> <028eee50-f14f-034d-6e8a-9d07276543b5@virtuozzo.com>
 <CAAeHK+xOnrF9yeN-ph4Otv=SueZqndk+=XiVu-FRPs8RV5poaw@mail.gmail.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Fri, 3 Mar 2017 15:18:53 +0100
Message-ID: <CAAeHK+wCr3=fxAN_gjH6nGo-r8bJMZyEu3fCmQq06CWpvtVLJw@mail.gmail.com>
Subject: Re: [PATCH v2 5/9] kasan: change report header
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, Mar 3, 2017 at 3:18 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> On Fri, Mar 3, 2017 at 2:21 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
>>
>>
>> On 03/02/2017 04:48 PM, Andrey Konovalov wrote:
>>
>>> diff --git a/mm/kasan/report.c b/mm/kasan/report.c
>>> index 8b0b27eb37cd..945d0e13e8a4 100644
>>> --- a/mm/kasan/report.c
>>> +++ b/mm/kasan/report.c
>>> @@ -130,11 +130,11 @@ static void print_error_description(struct kasan_access_info *info)
>>>  {
>>>       const char *bug_type = get_bug_type(info);
>>>
>>> -     pr_err("BUG: KASAN: %s in %pS at addr %p\n",
>>> -             bug_type, (void *)info->ip, info->access_addr);
>>> -     pr_err("%s of size %zu by task %s/%d\n",
>>> +     pr_err("BUG: KASAN: %s in %pS\n",
>>> +             bug_type, (void *)info->ip);
>>
>> This should fit in one line without exceeding 80-char limit.
>
> You mean the code or the header?
> The code fits, the header has much higher chances to fit after the change.

Ah, got you, will fix.

>
>>
>> --
>> You received this message because you are subscribed to the Google Groups "kasan-dev" group.
>> To unsubscribe from this group and stop receiving emails from it, send an email to kasan-dev+unsubscribe@googlegroups.com.
>> To post to this group, send email to kasan-dev@googlegroups.com.
>> To view this discussion on the web visit https://groups.google.com/d/msgid/kasan-dev/028eee50-f14f-034d-6e8a-9d07276543b5%40virtuozzo.com.
>> For more options, visit https://groups.google.com/d/optout.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
