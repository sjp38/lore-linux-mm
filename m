Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9F2B66B0268
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 15:20:42 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id s28so9700353pfg.6
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 12:20:42 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 34sor4219395plz.143.2017.11.20.12.20.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 Nov 2017 12:20:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <37111d5b-7042-dfff-9ac7-8733b77930e8@oracle.com>
References: <20171117223043.7277-1-wen.gang.wang@oracle.com>
 <CACT4Y+ZkC8R1vL+=j4Ordr2-4BWAc8Um+hdxPPWS6_DFi58ZJA@mail.gmail.com>
 <20171120015000.GA13507@js1304-P5Q-DELUXE> <CACT4Y+Zi9bNdnei_kXWu_3BHOobbhOgRKJ6Vk9QGs3c6NCdqXw@mail.gmail.com>
 <37111d5b-7042-dfff-9ac7-8733b77930e8@oracle.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 20 Nov 2017 21:20:20 +0100
Message-ID: <CACT4Y+ZEvLJbM_b6nWqLPvVJgWjAp-eYsmbO5vT2qQ3_zH-2+A@mail.gmail.com>
Subject: Re: [PATCH 0/5] mm/kasan: advanced check
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wengang <wen.gang.wang@oracle.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>

On Mon, Nov 20, 2017 at 9:05 PM, Wengang <wen.gang.wang@oracle.com> wrote:
>
>
> On 11/20/2017 12:41 AM, Dmitry Vyukov wrote:
>>
>>
>>>
>>> The reason I didn't submit the vchecker to mainline is that I didn't find
>>> the case that this tool is useful in real life. Most of the system broken
>>> case
>>> can be debugged by other ways. Do you see the real case that this tool is
>>> helpful?
>>
>> Hi,
>>
>> Yes, this is the main question here.
>> How is it going to be used in real life? How widely?
>>
>
> I think the owner check can be enabled in the cases where KASAN is used. --
> That is that we found there is memory issue, but don't know how it happened.


But KASAN generally pinpoints the corruption as it happens. Why do we
need something else?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
