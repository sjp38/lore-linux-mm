Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 396836B0387
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 22:25:53 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id x63so2487884pfx.7
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 19:25:53 -0800 (PST)
Received: from out4434.biz.mail.alibaba.com (out4434.biz.mail.alibaba.com. [47.88.44.34])
        by mx.google.com with ESMTP id x185si6281048pfd.237.2017.03.01.19.25.50
        for <linux-mm@kvack.org>;
        Wed, 01 Mar 2017 19:25:52 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170228214007.5621-1-hannes@cmpxchg.org> <20170228214007.5621-3-hannes@cmpxchg.org>
In-Reply-To: <20170228214007.5621-3-hannes@cmpxchg.org>
Subject: Re: [PATCH 2/9] mm: fix check for reclaimable pages in PF_MEMALLOC reclaim throttling
Date: Thu, 02 Mar 2017 11:25:34 +0800
Message-ID: <077d01d29304$a7d4d060$f77e7120$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Johannes Weiner' <hannes@cmpxchg.org>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'Jia He' <hejianet@gmail.com>, 'Michal Hocko' <mhocko@suse.cz>, 'Mel Gorman' <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com


On March 01, 2017 5:40 AM Johannes Weiner wrote: 
> 
> PF_MEMALLOC direct reclaimers get throttled on a node when the sum of
> all free pages in each zone fall below half the min watermark. During
> the summation, we want to exclude zones that don't have reclaimables.
> Checking the same pgdat over and over again doesn't make sense.
> 
> Fixes: 599d0c954f91 ("mm, vmscan: move LRU lists to node")
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
