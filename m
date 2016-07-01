Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id 918186B0005
	for <linux-mm@kvack.org>; Fri,  1 Jul 2016 10:03:14 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id d128so60367756vkg.0
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 07:03:14 -0700 (PDT)
Received: from mail-vk0-x236.google.com (mail-vk0-x236.google.com. [2607:f8b0:400c:c05::236])
        by mx.google.com with ESMTPS id m33si269188uam.120.2016.07.01.07.03.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 01 Jul 2016 07:03:13 -0700 (PDT)
Received: by mail-vk0-x236.google.com with SMTP id u68so111631298vkf.2
        for <linux-mm@kvack.org>; Fri, 01 Jul 2016 07:03:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1467381332-7282-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <57765157.8020909@virtuozzo.com> <1467381332-7282-1-git-send-email-iamjoonsoo.kim@lge.com>
From: Joonsoo Kim <js1304@gmail.com>
Date: Fri, 1 Jul 2016 23:03:13 +0900
Message-ID: <CAAmzW4PsBLLfcbOEfrtGogEfS7+9_EqOR5-Ho+UTi==8PwipMw@mail.gmail.com>
Subject: Re: [PATCH v2] kasan/quarantine: fix bugs on qlist_move_cache()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

2016-07-01 22:55 GMT+09:00  <js1304@gmail.com>:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> There are two bugs on qlist_move_cache(). One is that qlist's tail
> isn't set properly. curr->next can be NULL since it is singly linked
> list and NULL value on tail is invalid if there is one item on qlist.
> Another one is that if cache is matched, qlist_put() is called and
> it will set curr->next to NULL. It would cause to stop the loop
> prematurely.
>
> These problems come from complicated implementation so I'd like to
> re-implement it completely. Implementation in this patch is really
> simple. Iterate all qlist_nodes and put them to appropriate list.
>
> Unfortunately, I got this bug sometime ago and lose oops message.
> But, the bug looks trivial and no need to attach oops.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Please ignore this. It causes build warning. Please see v3.
Sorry for noise.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
