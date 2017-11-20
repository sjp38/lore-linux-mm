Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2420C6B0033
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 15:29:16 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id t126so5395679qkb.6
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 12:29:16 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id l57si1348376qtk.219.2017.11.20.12.29.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Nov 2017 12:29:15 -0800 (PST)
Subject: Re: [PATCH 0/5] mm/kasan: advanced check
References: <20171117223043.7277-1-wen.gang.wang@oracle.com>
 <CACT4Y+ZkC8R1vL+=j4Ordr2-4BWAc8Um+hdxPPWS6_DFi58ZJA@mail.gmail.com>
 <20171120015000.GA13507@js1304-P5Q-DELUXE>
 <CACT4Y+Zi9bNdnei_kXWu_3BHOobbhOgRKJ6Vk9QGs3c6NCdqXw@mail.gmail.com>
 <37111d5b-7042-dfff-9ac7-8733b77930e8@oracle.com>
 <CACT4Y+ZEvLJbM_b6nWqLPvVJgWjAp-eYsmbO5vT2qQ3_zH-2+A@mail.gmail.com>
From: Wengang <wen.gang.wang@oracle.com>
Message-ID: <de1e0f95-4daa-0b00-a7bf-0ce2e9a3371b@oracle.com>
Date: Mon, 20 Nov 2017 12:29:11 -0800
MIME-Version: 1.0
In-Reply-To: <CACT4Y+ZEvLJbM_b6nWqLPvVJgWjAp-eYsmbO5vT2qQ3_zH-2+A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>



On 11/20/2017 12:20 PM, Dmitry Vyukov wrote:
> On Mon, Nov 20, 2017 at 9:05 PM, Wengang <wen.gang.wang@oracle.com> wrote:
>>
>> On 11/20/2017 12:41 AM, Dmitry Vyukov wrote:
>>>
>>>> The reason I didn't submit the vchecker to mainline is that I didn't find
>>>> the case that this tool is useful in real life. Most of the system broken
>>>> case
>>>> can be debugged by other ways. Do you see the real case that this tool is
>>>> helpful?
>>> Hi,
>>>
>>> Yes, this is the main question here.
>>> How is it going to be used in real life? How widely?
>>>
>> I think the owner check can be enabled in the cases where KASAN is used. --
>> That is that we found there is memory issue, but don't know how it happened.
>
> But KASAN generally pinpoints the corruption as it happens. Why do we
> need something else?

Currently (without this patch set) kasan can't detect the overwritten 
issues that happen on allocated memory.

Say, A allocated a 128 bytes memory and B write to that memory at offset 
0 with length 100 unexpectedly.  Currently kasan won't report error for 
any writing to the offset 0 with len <= 128 including the B writting.  
This patch lets kasan report the B writing to offset 0 with length 100.

thanks,
wengang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
