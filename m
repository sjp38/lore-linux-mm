Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 999F06B025F
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 06:29:07 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r5so24921326wmr.0
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 03:29:07 -0700 (PDT)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id s70si483042wme.28.2016.06.16.03.29.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 16 Jun 2016 03:29:06 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id 22125991FA
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 10:29:06 +0000 (UTC)
Date: Thu, 16 Jun 2016 11:29:04 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 10/27] mm, vmscan: Clear congestion, dirty and need for
 compaction on a per-node basis
Message-ID: <20160616102904.GH1868@techsingularity.net>
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-11-git-send-email-mgorman@techsingularity.net>
 <510d374a-074e-cd32-bdbe-61754052b21b@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <510d374a-074e-cd32-bdbe-61754052b21b@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jun 16, 2016 at 11:29:00AM +0200, Vlastimil Babka wrote:
> On 06/09/2016 08:04 PM, Mel Gorman wrote:
> >Congested and dirty tracking of a node and whether reclaim should stall
> >is still based on zone activity. This patch considers whether the kernel
> >should stall based on node-based reclaim activity.
> 
> I'm a bit confused about the description vs actual code.
> It appears to move some duplicated code to a related function, which is
> fine. The rest of callsites that didn't perform the clearing before
> (prepare_kswapd_sleep() and wakeup_kswapd()) might be a bit overkill, but
> won't hurt. But I don't see the part "considers whether the kernel
> should stall based on node-based reclaim activity". Is something missing?
> 

Tired when writing the changelog. Does this make more sense?

    mm, vmscan: Remove duplicate logic clearing node congestion and dirty state

    Reclaim may stall if there is too much dirty or congested data on a node.
    This was previously based on zone flags and the logic for clearing the
    flags is in two places. As congestion/dirty tracking is now tracked on
    a per-node basis, we can remove some duplicate logic.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
