Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4A4E66B025E
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 20:10:40 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 63so303271761pfx.0
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 17:10:40 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id iv7si37625609pac.17.2016.08.01.17.10.38
        for <linux-mm@kvack.org>;
        Mon, 01 Aug 2016 17:10:39 -0700 (PDT)
Date: Tue, 2 Aug 2016 09:11:38 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: vmscan: fix memcg-aware shrinkers not called on
 global reclaim
Message-ID: <20160802001138.GB6770@bbox>
References: <1470056590-7177-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
In-Reply-To: <1470056590-7177-1-git-send-email-vdavydov@virtuozzo.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Hillf Danton <hillf.zj@alibaba-inc.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@surriel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 01, 2016 at 04:03:10PM +0300, Vladimir Davydov wrote:
> We must call shrink_slab() for each memory cgroup on both global and
> memcg reclaim in shrink_node_memcg(). Commit d71df22b55099 accidentally
> changed that so that now shrink_slab() is only called with memcg != NULL
> on memcg reclaim. As a result, memcg-aware shrinkers (including
> dentry/inode) are never invoked on global reclaim. Fix that.
> 
> Fixes: d71df22b55099 ("mm, vmscan: begin reclaiming pages on a per-node basis")
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
