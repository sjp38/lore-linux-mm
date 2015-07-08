Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id D07216B0038
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 18:48:00 -0400 (EDT)
Received: by lbcpe5 with SMTP id pe5so64820674lbc.2
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 15:48:00 -0700 (PDT)
Received: from mail-la0-x22b.google.com (mail-la0-x22b.google.com. [2a00:1450:4010:c03::22b])
        by mx.google.com with ESMTPS id sj10si2850004lac.29.2015.07.08.15.47.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Jul 2015 15:47:58 -0700 (PDT)
Received: by laar3 with SMTP id r3so235456240laa.0
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 15:47:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <559C6CA6.1050809@lge.com>
References: <1436243785-24105-1-git-send-email-gioh.kim@lge.com>
	<20150707153701.bfcde75108d1fb8aaedc8134@linux-foundation.org>
	<559C68B3.3010105@lge.com>
	<20150707170746.1b91ba0d07382cbc9ba3db92@linux-foundation.org>
	<559C6CA6.1050809@lge.com>
Date: Thu, 9 Jul 2015 08:47:57 +1000
Message-ID: <CAPM=9txmUJ58=CAxDhf12Y3Y8wz7CGBy-Bd4pQ8YAAKDsCxU8w@mail.gmail.com>
Subject: Re: [RFCv3 0/5] enable migration of driver pages
From: Dave Airlie <airlied@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>, dri-devel <dri-devel@lists.freedesktop.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, jlayton@poochiereds.net, bfields@fieldses.org, vbabka@suse.cz, iamjoonsoo.kim@lge.com, Al Viro <viro@zeniv.linux.org.uk>, "Michael S. Tsirkin" <mst@redhat.com>, koct9i@gmail.com, minchan@kernel.org, aquini@redhat.com, linux-fsdevel@vger.kernel.org, "open list:VIRTIO CORE, NET..." <virtualization@lists.linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "open list:ABI/API" <linux-api@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, gunho.lee@lge.com, Gioh Kim <gurugio@hanmail.net>

>>
>>
>> Can the various in-kernel GPU drivers benefit from this?  If so, wiring
>> up one or more of those would be helpful?
>
>
> I'm sure that other in-kernel GPU drivers can have benefit.
> It must be helpful.
>
> If I was familiar with other in-kernel GPU drivers code, I tried to patch
> them.
> It's too bad.

I'll bring dri-devel into the loop here.

ARM GPU developers please take a look at this stuff, Laurent, Rob,
Eric I suppose.

Daniel Vetter you might have some opinions as well.

Dave.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
