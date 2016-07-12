Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id BECED6B0005
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 14:10:53 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 33so16097822lfw.1
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 11:10:53 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id t123si4822945wmt.136.2016.07.12.11.10.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 11:10:52 -0700 (PDT)
Date: Tue, 12 Jul 2016 14:10:48 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 27/34] mm, vmscan: Have kswapd reclaim from all zones if
 reclaiming and buffer_heads_over_limit
Message-ID: <20160712181048.GC7821@cmpxchg.org>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-28-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1467970510-21195-28-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 08, 2016 at 10:35:03AM +0100, Mel Gorman wrote:
> The buffer_heads_over_limit limit in kswapd is inconsistent with direct
> reclaim behaviour. It may force an an attempt to reclaim from all zones and
> then not reclaim at all because higher zones were balanced than required
> by the original request.
> 
> This patch will causes kswapd to consider reclaiming from all zones if
> buffer_heads_over_limit.  However, if there are eligible zones for the
> allocation request that woke kswapd then no reclaim will occur even if
> buffer_heads_over_limit. This avoids kswapd over-reclaiming just because
> buffer_heads_over_limit.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
