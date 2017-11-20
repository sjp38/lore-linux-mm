Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 470B16B0268
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 15:05:11 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id e41so7361446itd.5
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 12:05:11 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 23si8946447ioh.305.2017.11.20.12.05.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Nov 2017 12:05:10 -0800 (PST)
Subject: Re: [PATCH 0/5] mm/kasan: advanced check
References: <20171117223043.7277-1-wen.gang.wang@oracle.com>
 <CACT4Y+ZkC8R1vL+=j4Ordr2-4BWAc8Um+hdxPPWS6_DFi58ZJA@mail.gmail.com>
 <20171120015000.GA13507@js1304-P5Q-DELUXE>
 <CACT4Y+Zi9bNdnei_kXWu_3BHOobbhOgRKJ6Vk9QGs3c6NCdqXw@mail.gmail.com>
From: Wengang <wen.gang.wang@oracle.com>
Message-ID: <37111d5b-7042-dfff-9ac7-8733b77930e8@oracle.com>
Date: Mon, 20 Nov 2017 12:05:07 -0800
MIME-Version: 1.0
In-Reply-To: <CACT4Y+Zi9bNdnei_kXWu_3BHOobbhOgRKJ6Vk9QGs3c6NCdqXw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Linux-MM <linux-mm@kvack.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>



On 11/20/2017 12:41 AM, Dmitry Vyukov wrote:
>
>>
>> The reason I didn't submit the vchecker to mainline is that I didn't find
>> the case that this tool is useful in real life. Most of the system broken case
>> can be debugged by other ways. Do you see the real case that this tool is
>> helpful?
> Hi,
>
> Yes, this is the main question here.
> How is it going to be used in real life? How widely?
>

I think the owner check can be enabled in the cases where KASAN is used. 
-- That is that we found there is memory issue, but don't know how it 
happened.
It's not the first hit of problem -- no production system will run with 
KASAN enabled, KASAN is performance killer. And the use case is that we 
found the overwritten happened on some particular victims, we then want 
to add owner check on those victims.

thanks,
wengang

>
>> If so, I think that vchecker is more appropriate to be upstreamed.
>> Could you share your opinion?
>>
>> Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
