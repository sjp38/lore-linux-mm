Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 44C786B0038
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 23:05:01 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id b2so344048094pgc.6
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 20:05:01 -0700 (PDT)
Received: from out4435.biz.mail.alibaba.com (out4435.biz.mail.alibaba.com. [47.88.44.35])
        by mx.google.com with ESMTP id 90si13272144pfp.242.2017.03.13.20.04.58
        for <linux-mm@kvack.org>;
        Mon, 13 Mar 2017 20:05:00 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170313221920.7881-1-shakeelb@google.com>
In-Reply-To: <20170313221920.7881-1-shakeelb@google.com>
Subject: Re: [PATCH v2] mm: fix condition for throttle_direct_reclaim
Date: Tue, 14 Mar 2017 11:04:42 +0800
Message-ID: <09b201d29c6f$babfa370$303eea50$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Shakeel Butt' <shakeelb@google.com>, 'Johannes Weiner' <hannes@cmpxchg.org>, 'Mel Gorman' <mgorman@techsingularity.net>, 'Michal Hocko' <mhocko@suse.com>, 'Vlastimil Babka' <vbabka@suse.cz>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'Jia He' <hejianet@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org


On March 14, 2017 6:19 AM Shakeel Butt wrote: 
> 
> Recently kswapd has been modified to give up after MAX_RECLAIM_RETRIES
> number of unsucessful iterations. Before going to sleep, kswapd thread
> will unconditionally wakeup all threads sleeping on pfmemalloc_wait.
> However the awoken threads will recheck the watermarks and wake the
> kswapd thread and sleep again on pfmemalloc_wait. There is a chance
> of continuous back and forth between kswapd and direct reclaiming
> threads if the kswapd keep failing and thus defeat the purpose of
> adding backoff mechanism to kswapd. So, add kswapd_failures check
> on the throttle_direct_reclaim condition.
> 
> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> Suggested-by: Michal Hocko <mhocko@suse.com>
> Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
> ---

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
