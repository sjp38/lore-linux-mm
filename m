Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id 381E5828F2
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 09:06:31 -0500 (EST)
Received: by mail-ob0-f178.google.com with SMTP id ts10so198895076obc.1
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 06:06:31 -0800 (PST)
Received: from mail-ob0-x22b.google.com (mail-ob0-x22b.google.com. [2607:f8b0:4003:c01::22b])
        by mx.google.com with ESMTPS id wc7si8775465oeb.88.2016.03.02.06.06.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Mar 2016 06:06:30 -0800 (PST)
Received: by mail-ob0-x22b.google.com with SMTP id ts10so198894780obc.1
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 06:06:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160302123752.GE26686@dhcp22.suse.cz>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
	<20160203132718.GI6757@dhcp22.suse.cz>
	<alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
	<20160229203502.GW16930@dhcp22.suse.cz>
	<alpine.LSU.2.11.1602292251170.7563@eggly.anvils>
	<20160301133846.GF9461@dhcp22.suse.cz>
	<56D5DBF0.2020004@suse.cz>
	<20160302025507.GC22355@js1304-P5Q-DELUXE>
	<20160302123752.GE26686@dhcp22.suse.cz>
Date: Wed, 2 Mar 2016 23:06:29 +0900
Message-ID: <CAAmzW4OtbSTXpAjMes_fZUvi0fO4riygOh_K_zxQbDUNCWva+Q@mail.gmail.com>
Subject: Re: [PATCH 0/3] OOM detection rework v4
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Vlastimil Babka <vbabka@suse.cz>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

2016-03-02 21:37 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
> On Wed 02-03-16 11:55:07, Joonsoo Kim wrote:
>> On Tue, Mar 01, 2016 at 07:14:08PM +0100, Vlastimil Babka wrote:
> [...]
>> > Yes, compaction is historically quite careful to avoid making low
>> > memory conditions worse, and to prevent work if it doesn't look like
>> > it can ultimately succeed the allocation (so having not enough base
>> > pages means that compacting them is considered pointless). This
>> > aspect of preventing non-zero-order OOMs is somewhat unexpected :)
>>
>> It's better not to assume that compaction would succeed all the times.
>> Compaction has some limitations so it sometimes fails.
>> For example, in lowmem situation, it only scans small parts of memory
>> and if that part is fragmented by non-movable page, compaction would fail.
>> And, compaction would defer requests 64 times at maximum if successive
>> compaction failure happens before.
>>
>> Depending on compaction heavily is right direction to go but I think
>> that it's not ready for now. More reclaim would relieve problem.
>
> I really fail to see why. The reclaimable memory can be migrated as
> well, no? Relying on the order-0 reclaim makes only sense to get over
> wmarks.

Attached link on previous reply mentioned limitation of current compaction
implementation. Briefly speaking, It would not scan all range of memory
due to algorithm limitation so even if there is reclaimable memory that
can be also migrated, compaction could fail.

There is no such limitation on reclaim and that's why I think that compaction
is not ready for now.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
