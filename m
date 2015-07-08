Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id DE4076B0038
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 19:55:28 -0400 (EDT)
Received: by pacws9 with SMTP id ws9so141153379pac.0
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 16:55:28 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id kr2si6229327pdb.200.2015.07.08.16.55.26
        for <linux-mm@kvack.org>;
        Wed, 08 Jul 2015 16:55:28 -0700 (PDT)
Message-ID: <559DB86D.40000@lge.com>
Date: Thu, 09 Jul 2015 08:55:25 +0900
From: Gioh Kim <gioh.kim@lge.com>
MIME-Version: 1.0
Subject: Re: [RFCv3 0/5] enable migration of driver pages
References: <1436243785-24105-1-git-send-email-gioh.kim@lge.com>	<20150707153701.bfcde75108d1fb8aaedc8134@linux-foundation.org>	<559C68B3.3010105@lge.com>	<20150707170746.1b91ba0d07382cbc9ba3db92@linux-foundation.org>	<559C6CA6.1050809@lge.com> <CAPM=9txmUJ58=CAxDhf12Y3Y8wz7CGBy-Bd4pQ8YAAKDsCxU8w@mail.gmail.com>
In-Reply-To: <CAPM=9txmUJ58=CAxDhf12Y3Y8wz7CGBy-Bd4pQ8YAAKDsCxU8w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Airlie <airlied@gmail.com>, dri-devel <dri-devel@lists.freedesktop.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, jlayton@poochiereds.net, bfields@fieldses.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, Al Viro <viro@zeniv.linux.org.uk>, "Michael S. Tsirkin" <mst@redhat.com>, koct9i@gmail.com, minchan@kernel.org, aquini@redhat.com, linux-fsdevel@vger.kernel.org, "open list:VIRTIO CORE, NET..." <virtualization@lists.linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, open@kvack.org, list@kvack.org, ABI/API <linux-api@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, gunho.lee@lge.com, Gioh Kim <gurugio@hanmail.net>



2015-07-09 i??i ? 7:47i?? Dave Airlie i?'(e??) i?' e,?:
>>>
>>>
>>> Can the various in-kernel GPU drivers benefit from this?  If so, wiring
>>> up one or more of those would be helpful?
>>
>>
>> I'm sure that other in-kernel GPU drivers can have benefit.
>> It must be helpful.
>>
>> If I was familiar with other in-kernel GPU drivers code, I tried to patch
>> them.
>> It's too bad.
>
> I'll bring dri-devel into the loop here.
>
> ARM GPU developers please take a look at this stuff, Laurent, Rob,
> Eric I suppose.

I sent a patch, https://lkml.org/lkml/2015/3/24/1182, and my opinion about compaction
to ARM GPU developers via Korea ARM branch.
I got a reply that they had no time to review it.

I hope they're interested to this patch.


>
> Daniel Vetter you might have some opinions as well.
>
> Dave.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
