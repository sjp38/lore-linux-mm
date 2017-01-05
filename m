Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B2E1B6B0069
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 00:41:25 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id f188so1637109372pgc.1
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 21:41:25 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id j186si74768562pfb.193.2017.01.04.21.41.23
        for <linux-mm@kvack.org>;
        Wed, 04 Jan 2017 21:41:24 -0800 (PST)
Date: Thu, 5 Jan 2017 14:41:19 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/7] mm, vmscan: add active list aging tracepoint
Message-ID: <20170105054119.GB24371@bbox>
References: <20170104101942.4860-1-mhocko@kernel.org>
 <20170104101942.4860-3-mhocko@kernel.org>
 <20170104135244.GJ25453@dhcp22.suse.cz>
MIME-Version: 1.0
In-Reply-To: <20170104135244.GJ25453@dhcp22.suse.cz>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, Jan 04, 2017 at 02:52:47PM +0100, Michal Hocko wrote:
> With fixed triggered by Vlastimil it should be like this.
> ---
> From b3a1480b54bf10924a9cd09c6d8b274fc81ca4ad Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Tue, 27 Dec 2016 13:18:20 +0100
> Subject: [PATCH] mm, vmscan: add active list aging tracepoint
> 
> Our reclaim process has several tracepoints to tell us more about how
> things are progressing. We are, however, missing a tracepoint to track
> active list aging. Introduce mm_vmscan_lru_shrink_active which reports
> the number of
> 	- nr_taken is number of isolated pages from the active list
> 	- nr_referenced pages which tells us that we are hitting referenced
> 	  pages which are deactivated. If this is a large part of the
> 	  reported nr_deactivated pages then we might be hitting into
> 	  the active list too early because they might be still part of
> 	  the working set. This might help to debug performance issues.
> 	- nr_active pages which tells us how many pages are kept on the
> 	  active list - mostly exec file backed pages. A high number can
> 	  indicate that we might be trashing on executables.
> 
> Changes since v1
> - report nr_taken pages as per Minchan
> - report nr_activated as per Minchan
> - do not report nr_freed pages because that would add a tiny overhead to
>   free_hot_cold_page_list which is a hot path
> - do not report nr_unevictable because we can report this number via a
>   different and more generic tracepoint in putback_lru_page
> - fix move_active_pages_to_lru to report proper page count when we hit
>   into large pages
> - drop nr_scanned because this can be obtained from
>   trace_mm_vmscan_lru_isolate as per Minchan
> 
> Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>
> Acked-by: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Minchan Kim <minchan@kernel.org>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
