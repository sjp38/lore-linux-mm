Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 051A46B0387
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 22:19:41 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id u62so111328989pfk.1
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 19:19:40 -0800 (PST)
Received: from out0-131.mail.aliyun.com (out0-131.mail.aliyun.com. [140.205.0.131])
        by mx.google.com with ESMTP id i6si423148plk.296.2017.02.27.19.19.39
        for <linux-mm@kvack.org>;
        Mon, 27 Feb 2017 19:19:39 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <cover.1487965799.git.shli@fb.com> <2f87063c1e9354677b7618c647abde77b07561e5.1487965799.git.shli@fb.com>
In-Reply-To: <2f87063c1e9354677b7618c647abde77b07561e5.1487965799.git.shli@fb.com>
Subject: Re: [PATCH V5 3/6] mm: move MADV_FREE pages into LRU_INACTIVE_FILE list
Date: Tue, 28 Feb 2017 11:19:31 +0800
Message-ID: <06ef01d29171$7ace0620$706a1260$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Shaohua Li' <shli@fb.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kernel-team@fb.com, mhocko@suse.com, minchan@kernel.org, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On February 25, 2017 5:32 AM Shaohua Li wrote: 
> 
> madv MADV_FREE indicate pages are 'lazyfree'. They are still anonymous
> pages, but they can be freed without pageout. To destinguish them
> against normal anonymous pages, we clear their SwapBacked flag.
> 
> MADV_FREE pages could be freed without pageout, so they pretty much like
> used once file pages. For such pages, we'd like to reclaim them once
> there is memory pressure. Also it might be unfair reclaiming MADV_FREE
> pages always before used once file pages and we definitively want to
> reclaim the pages before other anonymous and file pages.
> 
> To speed up MADV_FREE pages reclaim, we put the pages into
> LRU_INACTIVE_FILE list. The rationale is LRU_INACTIVE_FILE list is tiny
> nowadays and should be full of used once file pages. Reclaiming
> MADV_FREE pages will not have much interfere of anonymous and active
> file pages. And the inactive file pages and MADV_FREE pages will be
> reclaimed according to their age, so we don't reclaim too many MADV_FREE
> pages too. Putting the MADV_FREE pages into LRU_INACTIVE_FILE_LIST also
> means we can reclaim the pages without swap support. This idea is
> suggested by Johannes.
> 
> This patch doesn't move MADV_FREE pages to LRU_INACTIVE_FILE list yet to
> avoid bisect failure, next patch will do it.
> 
> The patch is based on Minchan's original patch.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Shaohua Li <shli@fb.com>
> ---

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
