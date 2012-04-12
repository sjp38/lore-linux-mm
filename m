Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 54E3C6B00F1
	for <linux-mm@kvack.org>; Thu, 12 Apr 2012 05:32:13 -0400 (EDT)
Date: Thu, 12 Apr 2012 10:32:09 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/3] Removal of lumpy reclaim V2
Message-ID: <20120412093209.GM3789@suse.de>
References: <1334162298-18942-1-git-send-email-mgorman@suse.de>
 <4F85BC8E.3020400@redhat.com>
 <20120411175215.GI3789@suse.de>
 <4F85C813.2050206@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4F85C813.2050206@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Apr 11, 2012 at 02:06:11PM -0400, Rik van Riel wrote:
> On 04/11/2012 01:52 PM, Mel Gorman wrote:
> >On Wed, Apr 11, 2012 at 01:17:02PM -0400, Rik van Riel wrote:
> 
> >>Next step: get rid of __GFP_NO_KSWAPD for THP, first
> >>in the -mm kernel
> >>
> >
> >Initially the flag was introduced because kswapd reclaimed too
> >aggressively. One would like to believe that it would be less of a problem
> >now but we must avoid a situation where the CPU and reclaim cost of kswapd
> >exceeds the benefit of allocating a THP.
> 
> Since kswapd and the direct reclaim code now use
> the same conditionals for calling compaction,
> the cost ought to be identical.
> 

kswapd has different retry logic for reclaim and can stay awake if there
are continual calls to wakeup_kswapd() setting pgdat->kswapd_max_order
and kswapd makes forward progress. It's not identical enough that I would
express 100% confidence that it will be free of problems.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
