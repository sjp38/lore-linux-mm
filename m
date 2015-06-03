Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 8A30C900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 08:55:29 -0400 (EDT)
Received: by qkoo18 with SMTP id o18so4387167qko.1
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 05:55:29 -0700 (PDT)
Received: from mail-qk0-x230.google.com (mail-qk0-x230.google.com. [2607:f8b0:400d:c09::230])
        by mx.google.com with ESMTPS id o7si481110qhb.69.2015.06.03.05.55.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jun 2015 05:55:28 -0700 (PDT)
Received: by qkhg32 with SMTP id g32so4378377qkh.0
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 05:55:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150603035608.GA1652@swordfish>
References: <1433264166-31452-1-git-send-email-ddstreet@ieee.org>
 <1433279395.4861.100.camel@perches.com> <CALZtONBVobxH--GGGdJaETScMorHKCY5ferHct74B79QDNDb4w@mail.gmail.com>
 <1433280616.4861.102.camel@perches.com> <20150603035608.GA1652@swordfish>
From: Dan Streetman <ddstreet@ieee.org>
Date: Wed, 3 Jun 2015 08:55:05 -0400
Message-ID: <CALZtOND5TgiFgA-j7igmuiCx+MZN9d08BshQYiwPqpQTiXiqXg@mail.gmail.com>
Subject: Re: [PATCH] MAINTAINERS: add zpool
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Joe Perches <joe@perches.com>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>

On Tue, Jun 2, 2015 at 11:56 PM, Sergey Senozhatsky
<sergey.senozhatsky.work@gmail.com> wrote:
> On (06/02/15 14:30), Joe Perches wrote:
>> > >> +ZPOOL COMPRESSED PAGE STORAGE API
>> > >> +M:   Dan Streetman <ddstreet@ieee.org>
>> > >> +L:   linux-mm@kvack.org
>> > >> +S:   Maintained
>> > >> +F:   mm/zpool.c
>> > >> +F:   include/linux/zpool.h
>> > >
>> > > If zpool.h is only included from files in mm/,
>> > > maybe zpool.h should be moved to mm/ ?
>> >
>> > It *could* be included by others, e.g. drivers/block/zram.
>> >
>> > It currently is only used by zswap though, so yeah it could be moved
>> > to mm/.  Should I move it there, until (if ever) anyone outside of mm/
>> > wants to use it?
>>
>> Up to you.
>>
>> I think include/linux is a bit overstuffed and
>> whatever can be include local should be.
>>
>
> Hi,
>
> I agree, can be local for now. if zram will ever want to use zpool
> then we will move zpool.h to include/linux. just my 5 cents.

Ok.  I'll send a patch to move it from include/linux to mm/ and update
the drivers there that include it.


>
>         -ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
