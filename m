Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 0A5276B007D
	for <linux-mm@kvack.org>; Thu,  9 Jun 2011 11:02:11 -0400 (EDT)
Received: by pxi10 with SMTP id 10so1117288pxi.8
        for <linux-mm@kvack.org>; Thu, 09 Jun 2011 08:02:09 -0700 (PDT)
Date: Fri, 10 Jun 2011 00:02:00 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH v3 05/10] vmscan: make isolate_lru_page with filter
 aware
Message-ID: <20110609150200.GD4878@barrios-laptop>
References: <cover.1307455422.git.minchan.kim@gmail.com>
 <f101a50f11ffac79eff441c58eafbb5eceac0b47.1307455422.git.minchan.kim@gmail.com>
 <20110609140453.GX5247@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110609140453.GX5247@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Thu, Jun 09, 2011 at 03:04:53PM +0100, Mel Gorman wrote:
> On Tue, Jun 07, 2011 at 11:38:18PM +0900, Minchan Kim wrote:
> > In __zone_reclaim case, we don't want to shrink mapped page.
> > Nonetheless, we have isolated mapped page and re-add it into
> > LRU's head. It's unnecessary CPU overhead and makes LRU churning.
> > 
> 
> Gack, I should have keep reading. I didn't cop from the subject that

I should have used clear subject.

> __zone_reclaim would be updated. Still, it would have been easier to
> review if one patch introduced ISOLATE_CLEAN and updated the callers and
> this patch introduced ISOLATE_UNMAPPED and updated the relevant callers.

Agree. I will fix in later version.

> 
> > <SNIP>
> 
> -- 
> Mel Gorman
> SUSE Labs

-- 
Kind regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
