Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 3952F830B6
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 20:19:58 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id xk3so95421630obc.2
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 17:19:58 -0800 (PST)
Received: from mail-ob0-x236.google.com (mail-ob0-x236.google.com. [2607:f8b0:4003:c01::236])
        by mx.google.com with ESMTPS id oi10si2356053oeb.67.2016.02.18.17.19.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 17:19:57 -0800 (PST)
Received: by mail-ob0-x236.google.com with SMTP id xk3so95421424obc.2
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 17:19:57 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160218101909.GB503@swordfish>
References: <1455764556-13979-1-git-send-email-sergey.senozhatsky@gmail.com>
	<1455764556-13979-4-git-send-email-sergey.senozhatsky@gmail.com>
	<CAAmzW4O-yQ5GBTE-6WvCL-hZeqyW=k3Fzn4_9G2qkMmp=ceuJg@mail.gmail.com>
	<20160218095536.GA503@swordfish>
	<20160218101909.GB503@swordfish>
Date: Fri, 19 Feb 2016 10:19:57 +0900
Message-ID: <CAAmzW4NQt4jD2q92Hh4XFzt5fV=-i3J9eoxS3now6Y4Xw7OqGg@mail.gmail.com>
Subject: Re: [RFC PATCH 3/3] mm/zsmalloc: change ZS_MAX_PAGES_PER_ZSPAGE
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

2016-02-18 19:19 GMT+09:00 Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com>:
> On (02/18/16 18:55), Sergey Senozhatsky wrote:
>> > There is a reason that it is order of 2. Increasing ZS_MAX_PAGES_PER_ZSPAGE
>> > is related to ZS_MIN_ALLOC_SIZE. If we don't have enough OBJ_INDEX_BITS,
>> > ZS_MIN_ALLOC_SIZE would be increase and it causes regression on some
>> > system.
>>
>> Thanks!
>>
>> do you mean PHYSMEM_BITS != BITS_PER_LONG systems? PAE/LPAE? isn't it
>> the case that on those systems ZS_MIN_ALLOC_SIZE already bigger than 32?

Indeed.

> I mean, yes, there are ZS_ALIGN requirements that I completely ignored,
> thanks for pointing that out.
>
> just saying, not insisting on anything, theoretically, trading 32 bit size
> objects in exchange of reducing a much bigger memory wastage is sort of
> interesting. zram stores objects bigger than 3072 as huge objects, leaving

I'm also just saying. :)
On the above example system which already uses 128 byte min class,
your change makes it to 160 or 192. It could make a more trouble than
you thought.

> 4096-3072 bytes unused, and it'll take 4096-3072/32 = 4000  32 bit objects
> to beat that single 'bad' compression object in storing inefficiency...

Where does 4096-3072/32 calculation comes from? I'm not familiar to recent
change on zsmalloc such as huge class so can't understand this calculation.

> well, patches 0001/0002 are trying to address this a bit, but the biggest
> problem is still there: we have too many ->huge classes and they are a bit
> far from good.

Agreed. And I agree your patchset, too.

Anyway, could you answer my other questions on original reply?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
