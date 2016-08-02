Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6DFCE6B0005
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 05:32:11 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id o80so99141137wme.1
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 02:32:11 -0700 (PDT)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id m22si2244343wmc.79.2016.08.02.02.32.10
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 02 Aug 2016 02:32:10 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id DBD6D9922B
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 09:32:09 +0000 (UTC)
Date: Tue, 2 Aug 2016 10:32:08 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: vmscan: fix memcg-aware shrinkers not called on
 global reclaim
Message-ID: <20160802093208.GH2799@techsingularity.net>
References: <1470056590-7177-1-git-send-email-vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1470056590-7177-1-git-send-email-vdavydov@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@surriel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 01, 2016 at 04:03:10PM +0300, Vladimir Davydov wrote:
> We must call shrink_slab() for each memory cgroup on both global and
> memcg reclaim in shrink_node_memcg(). Commit d71df22b55099 accidentally
> changed that so that now shrink_slab() is only called with memcg != NULL
> on memcg reclaim. As a result, memcg-aware shrinkers (including
> dentry/inode) are never invoked on global reclaim. Fix that.
> 
> Fixes: d71df22b55099 ("mm, vmscan: begin reclaiming pages on a per-node basis")
> Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
