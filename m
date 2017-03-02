Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5C1486B0387
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 22:27:22 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id f21so78349531pgi.4
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 19:27:22 -0800 (PST)
Received: from out0-139.mail.aliyun.com (out0-139.mail.aliyun.com. [140.205.0.139])
        by mx.google.com with ESMTP id w6si218783pgg.15.2017.03.01.19.27.20
        for <linux-mm@kvack.org>;
        Wed, 01 Mar 2017 19:27:21 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170228214007.5621-1-hannes@cmpxchg.org> <20170228214007.5621-4-hannes@cmpxchg.org>
In-Reply-To: <20170228214007.5621-4-hannes@cmpxchg.org>
Subject: Re: [PATCH 3/9] mm: remove seemingly spurious reclaimability check from laptop_mode gating
Date: Thu, 02 Mar 2017 11:27:15 +0800
Message-ID: <077e01d29304$e3c9c850$ab5d58f0$@alibaba-inc.com>
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
> 1d82de618ddd ("mm, vmscan: make kswapd reclaim in terms of nodes")
> allowed laptop_mode=1 to start writing not just when the priority
> drops to DEF_PRIORITY - 2 but also when the node is unreclaimable.
> That appears to be a spurious change in this patch as I doubt the
> series was tested with laptop_mode, and neither is that particular
> change mentioned in the changelog. Remove it, it's still recent.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
