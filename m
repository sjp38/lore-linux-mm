Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 115096B025E
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 03:44:17 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id na2so23488428lbb.1
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 00:44:17 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id e13si15369191wme.10.2016.06.16.00.44.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Jun 2016 00:44:15 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail04.blacknight.ie [81.17.254.17])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id 1CB3398668
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 07:44:15 +0000 (UTC)
Date: Thu, 16 Jun 2016 08:44:13 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 05/27] mm, vmscan: Have kswapd only scan based on the
 highest requested zone
Message-ID: <20160616074413.GE1868@techsingularity.net>
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-6-git-send-email-mgorman@techsingularity.net>
 <dea59a5e-eaf4-58d7-412b-b543ceb8709a@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <dea59a5e-eaf4-58d7-412b-b543ceb8709a@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jun 15, 2016 at 03:13:13PM +0200, Vlastimil Babka wrote:
> On 06/09/2016 08:04 PM, Mel Gorman wrote:
> >kswapd checks all eligible zones to see if they need balancing even if it was
> >woken for a lower zone. This made sense when we reclaimed on a per-zone basis
> >because we wanted to shrink zones fairly so avoid age-inversion problems.
> 
> Now we reclaim a single lru, but still will skip over pages from the higher
> zones than reclaim_idx, so this is not much different from per-zone basis
> wrt age-inversion?
> 

Yes, but it only applies in the case where the allocation request is zone
restricted. Previously, even with fair zone allocation policy, we had
problems with a high zone with recently allocated pages being reclaimed
simply because the low watermark was reached. Think of bugs in the past
where the normal zone was a small percentage of memory.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
