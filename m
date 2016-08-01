Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id CCAE1828E2
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 09:27:06 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 1so82361719wmz.2
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 06:27:06 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id sj15si31363785wjb.130.2016.08.01.06.27.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Aug 2016 06:27:05 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id i5so26179853wmg.2
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 06:27:05 -0700 (PDT)
Date: Mon, 1 Aug 2016 15:27:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: vmscan: fix memcg-aware shrinkers not called on
 global reclaim
Message-ID: <20160801132703.GF13544@dhcp22.suse.cz>
References: <1470056590-7177-1-git-send-email-vdavydov@virtuozzo.com>
 <20160801131840.GE13544@dhcp22.suse.cz>
 <20160801132145.GA19395@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160801132145.GA19395@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Hillf Danton <hillf.zj@alibaba-inc.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@surriel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 01-08-16 16:21:45, Vladimir Davydov wrote:
> On Mon, Aug 01, 2016 at 03:18:40PM +0200, Michal Hocko wrote:
> > On Mon 01-08-16 16:03:10, Vladimir Davydov wrote:
> > > We must call shrink_slab() for each memory cgroup on both global and
> > > memcg reclaim in shrink_node_memcg(). Commit d71df22b55099 accidentally
> > > changed that so that now shrink_slab() is only called with memcg != NULL
> > > on memcg reclaim. As a result, memcg-aware shrinkers (including
> > > dentry/inode) are never invoked on global reclaim. Fix that.
> > > 
> > > Fixes: d71df22b55099 ("mm, vmscan: begin reclaiming pages on a per-node basis")
> > 
> > I guess you meant b2e18757f2c9. I do not see d71df22b55099 anywhere.
> 
> I'm basing on top of v4.7-mmotm-2016-07-28-16-33 and there it's
> d71df22b55099.

But this sha is unstable. THe patch you are referring to is already
sitting in the Linus tree so please use his (stable sha instead).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
