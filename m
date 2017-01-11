Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2D26A6B0033
	for <linux-mm@kvack.org>; Wed, 11 Jan 2017 01:22:30 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 127so778372203pfg.5
        for <linux-mm@kvack.org>; Tue, 10 Jan 2017 22:22:30 -0800 (PST)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTP id m23si4728049plk.231.2017.01.10.22.22.28
        for <linux-mm@kvack.org>;
        Tue, 10 Jan 2017 22:22:29 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170110125552.4170-1-mhocko@kernel.org> <20170110125552.4170-3-mhocko@kernel.org>
In-Reply-To: <20170110125552.4170-3-mhocko@kernel.org>
Subject: Re: [RFC PATCH 2/2] mm, vmscan: cleanup inactive_list_is_low
Date: Wed, 11 Jan 2017 14:22:13 +0800
Message-ID: <020301d26bd3$0c6e6a80$254b3f80$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>, linux-mm@kvack.org
Cc: 'Johannes Weiner' <hannes@cmpxchg.org>, 'Mel Gorman' <mgorman@suse.de>, 'Minchan Kim' <minchan@kernel.org>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Michal Hocko' <mhocko@suse.com>


On Tuesday, January 10, 2017 8:56 PM Michal Hocko wrote: 
> 
> From: Michal Hocko <mhocko@suse.com>
> 
> inactive_list_is_low is duplicating logic implemented by
> lruvec_lru_size_eligibe_zones. Let's use the dedicated function to get
> the number of eligible pages on the lru list and ask use lruvec_lru_size
> to get the total LRU lize only when the tracing is really requested. We
> are still iterating over all LRUs two times in that case but a)
> inactive_list_is_low is not a hot path and b) this can be addressed at
> the tracing layer and only evaluate arguments only when the tracing is
> enabled in future if that ever matters.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
