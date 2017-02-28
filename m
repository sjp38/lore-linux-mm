Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4AE8F6B0388
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 22:21:29 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id n89so108107866pfa.7
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 19:21:29 -0800 (PST)
Received: from out4434.biz.mail.alibaba.com (out4434.biz.mail.alibaba.com. [47.88.44.34])
        by mx.google.com with ESMTP id i12si433285pgn.235.2017.02.27.19.21.27
        for <linux-mm@kvack.org>;
        Mon, 27 Feb 2017 19:21:28 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <cover.1487965799.git.shli@fb.com> <14b8eb1d3f6bf6cc492833f183ac8c304e560484.1487965799.git.shli@fb.com>
In-Reply-To: <14b8eb1d3f6bf6cc492833f183ac8c304e560484.1487965799.git.shli@fb.com>
Subject: Re: [PATCH V5 4/6] mm: reclaim MADV_FREE pages
Date: Tue, 28 Feb 2017 11:21:09 +0800
Message-ID: <06f001d29171$b5469740$1fd3c5c0$@alibaba-inc.com>
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
> When memory pressure is high, we free MADV_FREE pages. If the pages are
> not dirty in pte, the pages could be freed immediately. Otherwise we
> can't reclaim them. We put the pages back to anonumous LRU list (by
> setting SwapBacked flag) and the pages will be reclaimed in normal
> swapout way.
> 
> We use normal page reclaim policy. Since MADV_FREE pages are put into
> inactive file list, such pages and inactive file pages are reclaimed
> according to their age. This is expected, because we don't want to
> reclaim too many MADV_FREE pages before used once pages.
> 
> Based on Minchan's original patch
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Shaohua Li <shli@fb.com>
> ---

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
