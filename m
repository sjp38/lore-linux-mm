Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 190416B02D6
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 04:31:13 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id b189so52553wmd.5
        for <linux-mm@kvack.org>; Tue, 28 Nov 2017 01:31:13 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u10si4515542edf.527.2017.11.28.01.31.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 28 Nov 2017 01:31:12 -0800 (PST)
Date: Tue, 28 Nov 2017 10:31:08 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/vmscan: try to optimize branch procedures.
Message-ID: <20171128093108.btuna7xp4yzkziuj@dhcp22.suse.cz>
References: <20171128080339.i3ktwm565pz7om4v@dhcp22.suse.cz>
 <201711281719103258154@zte.com.cn>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <201711281719103258154@zte.com.cn>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jiang.biao2@zte.com.cn
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, zhong.weidong@zte.com.cn

On Tue 28-11-17 17:19:10, jiang.biao2@zte.com.cn wrote:
> > On Tue 28-11-17 09:49:45, Jiang Biao wrote:> > 1. Use unlikely to try to improve branch prediction. The
> > > *total_scan < 0* branch is unlikely to reach, so use unlikely.
> > >
> > > 2. Optimize *next_deferred >= scanned* condition.
> > > *next_deferred >= scanned* condition could be optimized into
> > > *next_deferred > scanned*, because when *next_deferred == scanned*,
> > > next_deferred shoud be 0, which is covered by the else branch.
> > >
> > > 3. Merge two branch blocks into one. The *next_deferred > 0* branch
> > > could be merged into *next_deferred > scanned* to simplify the code.
> > 
> > How have you measured benefit of this patch?
> No accurate measurement for now.
> Theoretically, unlikely could improve branch prediction for unlikely branch.

Yes, except that this is a slow path and I suspect that branch
prediction has minimal if at all.

> It's hard to measure the benefit of 2 and 3, any idea to do that enlightened 
> would be greatly appreciated. :) But it could simply code logic from coding 
> perspectivea??

Well, in general I wouldn't touch the code without a clear benefit.
Theoretical but unmeasurable changes would require a bigger benefit.
I am not saying it is wrong at all but I am not conviced your patch is
really worth merging.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
