Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 05DCF6B0387
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 22:31:18 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id u62so69604931pfk.1
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 19:31:17 -0800 (PST)
Received: from out0-152.mail.aliyun.com (out0-152.mail.aliyun.com. [140.205.0.152])
        by mx.google.com with ESMTP id a21si6290680pgi.248.2017.03.01.19.31.16
        for <linux-mm@kvack.org>;
        Wed, 01 Mar 2017 19:31:17 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170228214007.5621-1-hannes@cmpxchg.org> <20170228214007.5621-6-hannes@cmpxchg.org>
In-Reply-To: <20170228214007.5621-6-hannes@cmpxchg.org>
Subject: Re: [PATCH 5/9] mm: don't avoid high-priority reclaim on unreclaimable nodes
Date: Thu, 02 Mar 2017 11:31:01 +0800
Message-ID: <078001d29305$6ae1fb00$40a5f100$@alibaba-inc.com>
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
> 246e87a93934 ("memcg: fix get_scan_count() for small targets") sought
> to avoid high reclaim priorities for kswapd by forcing it to scan a
> minimum amount of pages when lru_pages >> priority yielded nothing.
> 
> b95a2f2d486d ("mm: vmscan: convert global reclaim to per-memcg LRU
> lists"), due to switching global reclaim to a round-robin scheme over
> all cgroups, had to restrict this forceful behavior to unreclaimable
> zones in order to prevent massive overreclaim with many cgroups.
> 
> The latter patch effectively neutered the behavior completely for all
> but extreme memory pressure. But in those situations we might as well
> drop the reclaimers to lower priority levels. Remove the check.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  mm/vmscan.c | 19 +++++--------------
>  1 file changed, 5 insertions(+), 14 deletions(-)
> 
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
