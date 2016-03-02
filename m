Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 271DA828E1
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 07:37:56 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id n186so83411268wmn.1
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 04:37:56 -0800 (PST)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id n67si4641156wmf.61.2016.03.02.04.37.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Mar 2016 04:37:55 -0800 (PST)
Received: by mail-wm0-f68.google.com with SMTP id 1so9361685wmg.2
        for <linux-mm@kvack.org>; Wed, 02 Mar 2016 04:37:54 -0800 (PST)
Date: Wed, 2 Mar 2016 13:37:53 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20160302123752.GE26686@dhcp22.suse.cz>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
 <20160229203502.GW16930@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602292251170.7563@eggly.anvils>
 <20160301133846.GF9461@dhcp22.suse.cz>
 <56D5DBF0.2020004@suse.cz>
 <20160302025507.GC22355@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160302025507.GC22355@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 02-03-16 11:55:07, Joonsoo Kim wrote:
> On Tue, Mar 01, 2016 at 07:14:08PM +0100, Vlastimil Babka wrote:
[...]
> > Yes, compaction is historically quite careful to avoid making low
> > memory conditions worse, and to prevent work if it doesn't look like
> > it can ultimately succeed the allocation (so having not enough base
> > pages means that compacting them is considered pointless). This
> > aspect of preventing non-zero-order OOMs is somewhat unexpected :)
> 
> It's better not to assume that compaction would succeed all the times.
> Compaction has some limitations so it sometimes fails.
> For example, in lowmem situation, it only scans small parts of memory
> and if that part is fragmented by non-movable page, compaction would fail.
> And, compaction would defer requests 64 times at maximum if successive
> compaction failure happens before.
> 
> Depending on compaction heavily is right direction to go but I think
> that it's not ready for now. More reclaim would relieve problem.

I really fail to see why. The reclaimable memory can be migrated as
well, no? Relying on the order-0 reclaim makes only sense to get over
wmarks.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
