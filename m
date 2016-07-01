Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1649F828E2
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 10:18:02 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id j185so24065544ith.0
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 07:18:02 -0700 (PDT)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00138.outbound.protection.outlook.com. [40.107.0.138])
        by mx.google.com with ESMTPS id w132si1766326oif.142.2016.07.01.07.18.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 01 Jul 2016 07:18:01 -0700 (PDT)
Subject: Re: [PATCH v3] kasan/quarantine: fix bugs on qlist_move_cache()
References: <1467381733-18314-1-git-send-email-iamjoonsoo.kim@lge.com>
 <CACT4Y+ZgmmizB209CUMOnq_p=2=__Y8AH4qsq1SG0RYk2kvxbQ@mail.gmail.com>
 <CAAmzW4MfofvK7hM_hVbpZ0orWaLcWYGUQ7HRafeaqD49ACER6Q@mail.gmail.com>
 <CACT4Y+bVWR88KivuMnX9a9v1tkk8VhhxSVx6TjznPqxc26evjg@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <57767BCA.8010305@virtuozzo.com>
Date: Fri, 1 Jul 2016 17:18:50 +0300
MIME-Version: 1.0
In-Reply-To: <CACT4Y+bVWR88KivuMnX9a9v1tkk8VhhxSVx6TjznPqxc26evjg@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>, Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>



On 07/01/2016 05:15 PM, Dmitry Vyukov wrote:
> On Fri, Jul 1, 2016 at 4:09 PM, Joonsoo Kim <js1304@gmail.com> wrote:
>> 2016-07-01 23:03 GMT+09:00 Dmitry Vyukov <dvyukov@google.com>:

>>>> +
>>>> +               if (obj_cache == cache)
>>>> +                       qlist_put(to, qlink, cache->size);
>>>> +               else
>>>> +                       qlist_put(from, qlink, cache->size);
>>>
>>> This line is wrong. If obj_cache != cache, object size != cache->size.
>>> Quarantine contains objects of different sizes.
>>
>> You're right. 11 pm is not good time to work. :/
>> If it is fixed, the patch looks correct to you?
>> I will fix it and send v4 on next week.
> 
> 
> I don't see anything else wrong. But I need to see how you fix the size issue.
> Performance of this operation is not particularly critical, so the
> simpler the better.

Is there any other way besides obvious: s/cache->size/obj_cache->size ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
