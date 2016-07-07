Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7EA5A6B0253
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 06:55:19 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r190so15593607wmr.0
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 03:55:19 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id q6si1819833wjo.270.2016.07.07.03.55.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Jul 2016 03:55:18 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id F1A1198E33
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 10:55:17 +0000 (UTC)
Date: Thu, 7 Jul 2016 11:55:16 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 11/31] mm: vmscan: do not reclaim from kswapd if there is
 any eligible zone
Message-ID: <20160707105516.GT11498@techsingularity.net>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-12-git-send-email-mgorman@techsingularity.net>
 <20160705061117.GD28164@bbox>
 <20160705103806.GH11498@techsingularity.net>
 <20160706012554.GD12570@bbox>
 <20160706084200.GM11498@techsingularity.net>
 <20160707062701.GC18072@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160707062701.GC18072@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 07, 2016 at 03:27:01PM +0900, Minchan Kim wrote:
> > I'm not going to go with it for now because buffer_heads_over_limit is not
> > necessarily a problem unless lowmem is factor. We don't want background
> > reclaim to go ahead unnecessarily just because buffer_heads_over_limit.
> > It could be distinguished by only forcing reclaim to go ahead on systems
> > with highmem.
> 
> If you don't think it's a problem, I don't want to insist on it because I don't
> have any report/workload right now. Instead, please write some comment in there
> for others to understand why kswapd is okay to ignore buffer_heads_over_limit
> unlike direct reclaim. Such non-symmetric behavior is really hard to follow
> without any description.

Ok, I'll add a patch later in the series that addresses the issue.
Currently it's called "mm, vmscan: Have kswapd reclaim from all zones if
reclaiming and buffer_heads_over_limit".

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
