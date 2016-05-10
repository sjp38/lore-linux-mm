Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f199.google.com (mail-ig0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8AE8D6B025E
	for <linux-mm@kvack.org>; Tue, 10 May 2016 04:00:09 -0400 (EDT)
Received: by mail-ig0-f199.google.com with SMTP id kj7so15028617igb.3
        for <linux-mm@kvack.org>; Tue, 10 May 2016 01:00:09 -0700 (PDT)
Received: from mail-ob0-x22e.google.com (mail-ob0-x22e.google.com. [2607:f8b0:4003:c01::22e])
        by mx.google.com with ESMTPS id p204si312653oib.146.2016.05.10.01.00.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 May 2016 01:00:08 -0700 (PDT)
Received: by mail-ob0-x22e.google.com with SMTP id n10so2381091obb.2
        for <linux-mm@kvack.org>; Tue, 10 May 2016 01:00:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <57318932.3030804@suse.cz>
References: <1461181647-8039-1-git-send-email-mhocko@kernel.org>
	<20160504054502.GA10899@js1304-P5Q-DELUXE>
	<20160504084737.GB29978@dhcp22.suse.cz>
	<CAAmzW4M7ZT7+vUsW3SrTRSv6Q80B2NdAS+OX7PrnpdrV+=R19A@mail.gmail.com>
	<20160504181608.GA21490@dhcp22.suse.cz>
	<CAAmzW4NM-M39d7qp4B8J87moN3ESVgckbd01=pKXV1XEh6Y+6A@mail.gmail.com>
	<57318932.3030804@suse.cz>
Date: Tue, 10 May 2016 17:00:08 +0900
Message-ID: <CAAmzW4Nb+rV88+YbD+xHDVbOfu_3HpiTVQFy6CgXAoFhpD_+pA@mail.gmail.com>
Subject: Re: [PATCH 0.14] oom detection rework v6
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

2016-05-10 16:09 GMT+09:00 Vlastimil Babka <vbabka@suse.cz>:
> On 05/10/2016 08:41 AM, Joonsoo Kim wrote:
>>
>> You applied band-aid for CONFIG_COMPACTION and fixed some reported
>> problem but it is also fragile. Assume almost pageblock's skipbit are
>> set. In this case, compaction easily returns COMPACT_COMPLETE and your
>> logic will stop retry. Compaction isn't designed to report accurate
>> fragmentation state of the system so depending on it's return value
>> for OOM is fragile.
>
>
> Guess I'll just post a RFC now, even though it's not much tested...

I will look at it later. But, I'd like to say something first.
Even if compaction returns more accurate fragmentation states, it's not a good
idea to depend on compaction's result to decide OOM. We have reclaimable but
not migratable pages. Depending on compaction's result cannot deal
with this case.

For example, please assume that all of the system memory are filled
with THP pages
or reclaimable slab pages. They cannot be migrated but we can reclaim them.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
