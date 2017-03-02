Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8289A6B0387
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 22:32:55 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id x17so78340703pgi.3
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 19:32:55 -0800 (PST)
Received: from out0-129.mail.aliyun.com (out0-129.mail.aliyun.com. [140.205.0.129])
        by mx.google.com with ESMTP id r26si6271054pge.381.2017.03.01.19.32.54
        for <linux-mm@kvack.org>;
        Wed, 01 Mar 2017 19:32:54 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170228214007.5621-1-hannes@cmpxchg.org> <20170228214007.5621-7-hannes@cmpxchg.org>
In-Reply-To: <20170228214007.5621-7-hannes@cmpxchg.org>
Subject: Re: [PATCH 6/9] mm: don't avoid high-priority reclaim on memcg limit reclaim
Date: Thu, 02 Mar 2017 11:32:47 +0800
Message-ID: <078101d29305$aa290420$fe7b0c60$@alibaba-inc.com>
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
> to avoid high reclaim priorities for memcg by forcing it to scan a
> minimum amount of pages when lru_pages >> priority yielded nothing.
> This was done at a time when reclaim decisions like dirty throttling
> were tied to the priority level.
> 
> Nowadays, the only meaningful thing still tied to priority dropping
> below DEF_PRIORITY - 2 is gating whether laptop_mode=1 is generally
> allowed to write. But that is from an era where direct reclaim was
> still allowed to call ->writepage, and kswapd nowadays avoids writes
> until it's scanned every clean page in the system. Potential changes
> to how quick sc->may_writepage could trigger are of little concern.
> 
> Remove the force_scan stuff, as well as the ugly multi-pass target
> calculation that it necessitated.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
