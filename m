Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4DE346B0005
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 09:57:57 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id i44so254819672qte.3
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 06:57:57 -0700 (PDT)
Received: from mail-vk0-x22b.google.com (mail-vk0-x22b.google.com. [2607:f8b0:400c:c05::22b])
        by mx.google.com with ESMTPS id f184si1299646vkb.8.2016.07.01.06.57.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jul 2016 06:57:56 -0700 (PDT)
Received: by mail-vk0-x22b.google.com with SMTP id u68so111417844vkf.2
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 06:57:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <577625CC.8080907@virtuozzo.com>
References: <1467359628-8493-1-git-send-email-iamjoonsoo.kim@lge.com> <577625CC.8080907@virtuozzo.com>
From: Joonsoo Kim <js1304@gmail.com>
Date: Fri, 1 Jul 2016 22:57:55 +0900
Message-ID: <CAAmzW4P7+L9F7nx4zJKan6ytJ-55iCSaa7v1KC-h05N6VtmH8Q@mail.gmail.com>
Subject: Re: [PATCH] kasan/quarantine: fix NULL pointer dereference bug
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

2016-07-01 17:11 GMT+09:00 Andrey Ryabinin <aryabinin@virtuozzo.com>:
>
>
> On 07/01/2016 10:53 AM, js1304@gmail.com wrote:
>> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>
>> If we move an item on qlist's tail, we need to update qlist's tail
>> properly. curr->next can be NULL since it is singly linked list
>> so it is invalid for tail. curr is scheduled to be moved so
>> using prev would be correct.
>
> Hmm.. prev may be the element that moved in 'to' list. We need to assign the last element
> from which is in ther 'from' list.

You're right. Also, I find another bug on this function.
I manage them on v2 and sent.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
