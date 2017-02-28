Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 089EC6B0387
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 22:22:32 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 1so208509851pgz.5
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 19:22:32 -0800 (PST)
Received: from out0-152.mail.aliyun.com (out0-152.mail.aliyun.com. [140.205.0.152])
        by mx.google.com with ESMTP id w70si418295pgw.402.2017.02.27.19.22.30
        for <linux-mm@kvack.org>;
        Mon, 27 Feb 2017 19:22:31 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <cover.1487965799.git.shli@fb.com> <155648585589300bfae1d45078e7aebb3d988b87.1487965799.git.shli@fb.com>
In-Reply-To: <155648585589300bfae1d45078e7aebb3d988b87.1487965799.git.shli@fb.com>
Subject: Re: [PATCH V5 5/6] mm: enable MADV_FREE for swapless system
Date: Tue, 28 Feb 2017 11:22:19 +0800
Message-ID: <06f101d29171$df1716d0$9d454470$@alibaba-inc.com>
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
> Now MADV_FREE pages can be easily reclaimed even for swapless system. We
> can safely enable MADV_FREE for all systems.
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
