Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 58D166B0005
	for <linux-mm@kvack.org>; Tue, 12 Jul 2016 10:05:14 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id f126so14370575wma.3
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 07:05:14 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id c127si20756226wmd.112.2016.07.12.07.05.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Jul 2016 07:05:13 -0700 (PDT)
Date: Tue, 12 Jul 2016 10:05:04 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 06/34] mm, vmscan: have kswapd only scan based on the
 highest requested zone
Message-ID: <20160712140504.GC5881@cmpxchg.org>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-7-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1467970510-21195-7-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 08, 2016 at 10:34:42AM +0100, Mel Gorman wrote:
> kswapd checks all eligible zones to see if they need balancing even if it
> was woken for a lower zone.  This made sense when we reclaimed on a
> per-zone basis because we wanted to shrink zones fairly so avoid
> age-inversion problems.  Ideally this is completely unnecessary when
> reclaiming on a per-node basis.  In theory, there may still be anomalies
> when all requests are for lower zones and very old pages are preserved in
> higher zones but this should be the exceptional case.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

I wasn't quite sure at first what the rationale is for this patch,
since it probably won't make much difference in pratice. But I do
agree that the code is cleaner to have kswapd check exactly what it
was asked to check, rather than some do-the-"right"-thing magic.

A hypothetical onslaught of low-zone allocations will wreak havoc to
the page age in higher zones anyway, right? So I don't think that case
matters all that much.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
