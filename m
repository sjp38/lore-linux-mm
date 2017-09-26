Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id D522E6B0038
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 06:04:46 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id j189so8578213vka.0
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 03:04:46 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i12sor4299457uae.209.2017.09.26.03.04.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 26 Sep 2017 03:04:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170926095127.p5ocg44et2g62gku@techsingularity.net>
References: <1506415604-4310-1-git-send-email-zhuhui@xiaomi.com> <20170926095127.p5ocg44et2g62gku@techsingularity.net>
From: Hui Zhu <teawater@gmail.com>
Date: Tue, 26 Sep 2017 18:04:04 +0800
Message-ID: <CANFwon3Mf3AUfUPtSAUQus0yohMzKEirDcNqfnwPDwFWD04z-w@mail.gmail.com>
Subject: Re: [RFC 0/2] Use HighAtomic against long-term fragmentation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Hui Zhu <zhuhui@xiaomi.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, hillf.zj@alibaba-inc.com, Linux Memory Management List <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

2017-09-26 17:51 GMT+08:00 Mel Gorman <mgorman@techsingularity.net>:
> On Tue, Sep 26, 2017 at 04:46:42PM +0800, Hui Zhu wrote:
>> Current HighAtomic just to handle the high atomic page alloc.
>> But I found that use it handle the normal unmovable continuous page
>> alloc will help to against long-term fragmentation.
>>
>
> This is not wise. High-order atomic allocations do not always have a
> smooth recovery path such as network drivers with large MTUs that have no
> choice but to drop the traffic and hope for a retransmit. That's why they
> have the highatomic reserve. If the reserve is used for normal unmovable
> allocations then allocation requests that could have waited for reclaim
> may cause high-order atomic allocations to fail. Changing it may allow
> improve latencies in some limited cases while causing functional failures
> in others.  If there is a special case where there are a large number of
> other high-order allocations then I would suggest increasing min_free_kbytes
> instead as a workaround.

I think let 0 order unmovable page alloc and other order unmovable pages
alloc use different migrate types will help against long-term
fragmentation.

Do you think kernel can add a special migrate type for big than 0 order
unmovable pages alloc?

Thanks,
Hui

>
> --
> Mel Gorman
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
