Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7B5476B02B4
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 04:11:53 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id g131so3819348oic.10
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 01:11:53 -0700 (PDT)
Received: from mail-oi0-x22d.google.com (mail-oi0-x22d.google.com. [2607:f8b0:4003:c06::22d])
        by mx.google.com with ESMTPS id a196si217273oih.283.2017.08.16.01.11.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 01:11:52 -0700 (PDT)
Received: by mail-oi0-x22d.google.com with SMTP id f11so29256479oic.0
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 01:11:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170816045059.GD24294@blaptop>
References: <1502704590-3129-1-git-send-email-zhuhui@xiaomi.com>
 <20170816021339.GA23451@blaptop> <CANFwon3kDOUKcUBmihVzSwkQ34MOGkEnAkOdHET+uv8XBoAWfQ@mail.gmail.com>
 <20170816045059.GD24294@blaptop>
From: Hui Zhu <teawater@gmail.com>
Date: Wed, 16 Aug 2017 16:11:11 +0800
Message-ID: <CANFwon1mchPhutvCvu8Mk32C8U4b41bN_hoKZRxube=LL_Ew1A@mail.gmail.com>
Subject: Re: [PATCH v2] zsmalloc: zs_page_migrate: schedule free_work if
 zspage is ZS_EMPTY
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Hui Zhu <zhuhui@xiaomi.com>, "ngupta@vflare.org" <ngupta@vflare.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

2017-08-16 12:51 GMT+08:00 Minchan Kim <minchan@kernel.org>:
> On Wed, Aug 16, 2017 at 10:49:14AM +0800, Hui Zhu wrote:
>> Hi Minchan,
>>
>> 2017-08-16 10:13 GMT+08:00 Minchan Kim <minchan@kernel.org>:
>> > Hi Hui,
>> >
>> > On Mon, Aug 14, 2017 at 05:56:30PM +0800, Hui Zhu wrote:
>> >> After commit e2846124f9a2 ("zsmalloc: zs_page_migrate: skip unnecessary
>> >
>> > This patch is not merged yet so the hash is invalid.
>> > That means we may fold this patch to [1] in current mmotm.
>> >
>> > [1] zsmalloc-zs_page_migrate-skip-unnecessary-loops-but-not-return-ebusy-if-zspage-is-not-inuse-fix.patch
>> >
>> >> loops but not return -EBUSY if zspage is not inuse") zs_page_migrate
>> >> can handle the ZS_EMPTY zspage.
>> >>
>> >> But I got some false in zs_page_isolate:
>> >>       if (get_zspage_inuse(zspage) == 0) {
>> >>               spin_unlock(&class->lock);
>> >>               return false;
>> >>       }
>> >
>> > I also realized we should make zs_page_isolate succeed on empty zspage
>> > because we allow the empty zspage migration from now on.
>> > Could you send a patch for that as well?
>>
>> OK.  I will make a patch for that later.
>
> Please send the patch so I want to fold it to [1] before Andrew is going
> to send [1] to Linus.
>
> Thanks.

Done.

Thanks,
Hui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
