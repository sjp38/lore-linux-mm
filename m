Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id CE5296B025F
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 08:54:32 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id x83so54935405wma.2
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 05:54:32 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p18si3035036wmd.144.2016.07.14.05.54.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Jul 2016 05:54:30 -0700 (PDT)
Subject: Re: [PATCH 27/34] mm, vmscan: Have kswapd reclaim from all zones if
 reclaiming and buffer_heads_over_limit
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-28-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <6a33dd1a-ac19-ced1-a346-e83eea432780@suse.cz>
Date: Thu, 14 Jul 2016 14:54:27 +0200
MIME-Version: 1.0
In-Reply-To: <1467970510-21195-28-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On 07/08/2016 11:35 AM, Mel Gorman wrote:
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

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
