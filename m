Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 84C9D6B0038
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 08:45:48 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id t193so29114332wmt.4
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 05:45:48 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p11sor31298wmf.24.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Mar 2017 05:45:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <2bbe7bdc-8842-8ec0-4b5a-6a8dce39216d@virtuozzo.com>
References: <20170302134851.101218-1-andreyknvl@google.com>
 <20170302134851.101218-7-andreyknvl@google.com> <db0b6605-32bc-4c7a-0c99-2e60e4bdb11f@virtuozzo.com>
 <CAG_fn=Vn1tWsRbt4ohkE0E2ijAZsBvVuPS-Ond2KHVh9WK1zkg@mail.gmail.com> <2bbe7bdc-8842-8ec0-4b5a-6a8dce39216d@virtuozzo.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 6 Mar 2017 14:45:46 +0100
Message-ID: <CAAeHK+xnHx5fvhq158+oxMxieG7a+gG7i0MQS92DqxYGe0O=Ww@mail.gmail.com>
Subject: Re: [PATCH v2 6/9] kasan: improve slab object description
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Mar 3, 2017 at 3:39 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
>
>
> On 03/03/2017 04:52 PM, Alexander Potapenko wrote:
>> On Fri, Mar 3, 2017 at 2:31 PM, Andrey Ryabinin <aryabinin@virtuozzo.com> wrote:
>>> On 03/02/2017 04:48 PM, Andrey Konovalov wrote:
>>>> Changes slab object description from:
>>>>
>>>> Object at ffff880068388540, in cache kmalloc-128 size: 128
>>>>
>>>> to:
>>>>
>>>> The buggy address belongs to the object at ffff880068388540
>>>>  which belongs to the cache kmalloc-128 of size 128
>>>> The buggy address is located 123 bytes inside of
>>>>  128-byte region [ffff880068388540, ffff8800683885c0)
>>>>
>>>> Makes it more explanatory and adds information about relative offset
>>>> of the accessed address to the start of the object.
>>>>
>>>
>>> I don't think that this is an improvement. You replaced one simple line with a huge
>>> and hard to parse text without giving any new/useful information.
>>> Except maybe offset, it useful sometimes, so wouldn't mind adding it to description.
>> Agreed.
>> How about:
>> ===========
>> Access 123 bytes inside of 128-byte region [ffff880068388540, ffff8800683885c0)
>> Object at ffff880068388540 belongs to the cache kmalloc-128
>> ===========
>> ?
>>
>
> I would just add the offset in the end:
>         Object at ffff880068388540, in cache kmalloc-128 size: 128 accessed at offset y

Access can be inside or outside the object, so it's better to
specifically say that.

I think we can do (basically what Alexander suggested):

Object at ffff880068388540 belongs to the cache kmalloc-128 of size 128
Access 123 bytes inside of 128-byte region [ffff880068388540, ffff8800683885c0)

What do you think?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
