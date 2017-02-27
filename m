Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2CE136B038B
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 01:49:01 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id x17so4315362pgi.3
        for <linux-mm@kvack.org>; Sun, 26 Feb 2017 22:49:01 -0800 (PST)
Received: from out4435.biz.mail.alibaba.com (out4435.biz.mail.alibaba.com. [47.88.44.35])
        by mx.google.com with ESMTP id n67si14372083pfk.77.2017.02.26.22.48.59
        for <linux-mm@kvack.org>;
        Sun, 26 Feb 2017 22:49:00 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <cover.1487965799.git.shli@fb.com> <3945232c0df3dd6c4ef001976f35a95f18dcb407.1487965799.git.shli@fb.com>
In-Reply-To: <3945232c0df3dd6c4ef001976f35a95f18dcb407.1487965799.git.shli@fb.com>
Subject: Re: [PATCH V5 2/6] mm: don't assume anonymous pages have SwapBacked flag
Date: Mon, 27 Feb 2017 14:48:41 +0800
Message-ID: <06b701d290c5$8909bec0$9b1d3c40$@alibaba-inc.com>
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
> There are a few places the code assumes anonymous pages should have
> SwapBacked flag set. MADV_FREE pages are anonymous pages but we are
> going to add them to LRU_INACTIVE_FILE list and clear SwapBacked flag
> for them. The assumption doesn't hold any more, so fix them.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Shaohua Li <shli@fb.com>
> ---

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
