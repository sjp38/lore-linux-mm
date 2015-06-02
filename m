Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id F16E4900016
	for <linux-mm@kvack.org>; Tue,  2 Jun 2015 17:20:10 -0400 (EDT)
Received: by qkhg32 with SMTP id g32so108890647qkh.0
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 14:20:10 -0700 (PDT)
Received: from mail-qg0-x235.google.com (mail-qg0-x235.google.com. [2607:f8b0:400d:c04::235])
        by mx.google.com with ESMTPS id h1si13376318qhc.6.2015.06.02.14.20.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Jun 2015 14:20:10 -0700 (PDT)
Received: by qgg60 with SMTP id 60so64485738qgg.2
        for <linux-mm@kvack.org>; Tue, 02 Jun 2015 14:20:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1433279395.4861.100.camel@perches.com>
References: <1433264166-31452-1-git-send-email-ddstreet@ieee.org> <1433279395.4861.100.camel@perches.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Tue, 2 Jun 2015 17:19:49 -0400
Message-ID: <CALZtONBVobxH--GGGdJaETScMorHKCY5ferHct74B79QDNDb4w@mail.gmail.com>
Subject: Re: [PATCH] MAINTAINERS: add zpool
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Tue, Jun 2, 2015 at 5:09 PM, Joe Perches <joe@perches.com> wrote:
> On Tue, 2015-06-02 at 12:56 -0400, Dan Streetman wrote:
>> Add entry for zpool to MAINTAINERS file.
> []
>> diff --git a/MAINTAINERS b/MAINTAINERS
> []
>> @@ -11056,6 +11056,13 @@ L:   zd1211-devs@lists.sourceforge.net (subscribers-only)
>>  S:   Maintained
>>  F:   drivers/net/wireless/zd1211rw/
>>
>> +ZPOOL COMPRESSED PAGE STORAGE API
>> +M:   Dan Streetman <ddstreet@ieee.org>
>> +L:   linux-mm@kvack.org
>> +S:   Maintained
>> +F:   mm/zpool.c
>> +F:   include/linux/zpool.h
>
> If zpool.h is only included from files in mm/,
> maybe zpool.h should be moved to mm/ ?

It *could* be included by others, e.g. drivers/block/zram.

It currently is only used by zswap though, so yeah it could be moved
to mm/.  Should I move it there, until (if ever) anyone outside of mm/
wants to use it?

>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
