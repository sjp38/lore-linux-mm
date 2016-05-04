Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f198.google.com (mail-ig0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id BDE1C6B025E
	for <linux-mm@kvack.org>; Wed,  4 May 2016 11:17:13 -0400 (EDT)
Received: by mail-ig0-f198.google.com with SMTP id sq19so111419693igc.0
        for <linux-mm@kvack.org>; Wed, 04 May 2016 08:17:13 -0700 (PDT)
Received: from mail-ob0-x234.google.com (mail-ob0-x234.google.com. [2607:f8b0:4003:c01::234])
        by mx.google.com with ESMTPS id ul14si1977743oeb.63.2016.05.04.08.17.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 May 2016 08:17:12 -0700 (PDT)
Received: by mail-ob0-x234.google.com with SMTP id dm5so22184917obc.1
        for <linux-mm@kvack.org>; Wed, 04 May 2016 08:17:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAG_fn=VwrB3sb9RvMdj0qnafnbNONASTpkxj0zSE7spdEVi7hw@mail.gmail.com>
References: <1462252403-1106-1-git-send-email-iamjoonsoo.kim@lge.com>
	<CAG_fn=VwrB3sb9RvMdj0qnafnbNONASTpkxj0zSE7spdEVi7hw@mail.gmail.com>
Date: Thu, 5 May 2016 00:17:12 +0900
Message-ID: <CAAmzW4MRs-x5JF5XmEnHbPLJ5mRua_vPY_xpgivDyQvXc8HOSg@mail.gmail.com>
Subject: Re: [PATCH for v4.6] lib/stackdepot: avoid to return 0 handle
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Potapenko <glider@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

2016-05-04 17:34 GMT+09:00 Alexander Potapenko <glider@google.com>:
> On Tue, May 3, 2016 at 7:13 AM,  <js1304@gmail.com> wrote:
>> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>>
>> Recently, we allow to save the stacktrace whose hashed value is 0.
>> It causes the problem that stackdepot could return 0 even if in success.
>> User of stackdepot cannot distinguish whether it is success or not so we
>> need to solve this problem. In this patch, 1 bit are added to handle
>> and make valid handle none 0 by setting this bit. After that, valid handle
>> will not be 0 and 0 handle will represent failure correctly.
> Returning success or failure doesn't require a special bit, we can
> just make depot_alloc_stack() return a boolean value.
> If I'm understanding correctly, your primary intention is to reserve
> an invalid handle value that will never collide with valid handles
> returned in the future.
> Can you reflect this in the description?

Indeed. I will add it in the description and respin the patch.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
