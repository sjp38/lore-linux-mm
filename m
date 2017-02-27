Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 328346B0038
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 01:28:06 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 1so163133108pgz.5
        for <linux-mm@kvack.org>; Sun, 26 Feb 2017 22:28:06 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id l16si14313240pfg.206.2017.02.26.22.28.04
        for <linux-mm@kvack.org>;
        Sun, 26 Feb 2017 22:28:05 -0800 (PST)
Date: Mon, 27 Feb 2017 15:28:01 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH V5 3/6] mm: move MADV_FREE pages into LRU_INACTIVE_FILE
 list
Message-ID: <20170227062801.GB23612@bbox>
References: <cover.1487965799.git.shli@fb.com>
 <2f87063c1e9354677b7618c647abde77b07561e5.1487965799.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2f87063c1e9354677b7618c647abde77b07561e5.1487965799.git.shli@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

Hello Shaohua,

On Fri, Feb 24, 2017 at 01:31:46PM -0800, Shaohua Li wrote:
> madv MADV_FREE indicate pages are 'lazyfree'. They are still anonymous
> pages, but they can be freed without pageout. To destinguish them
> against normal anonymous pages, we clear their SwapBacked flag.
> 
> MADV_FREE pages could be freed without pageout, so they pretty much like
> used once file pages. For such pages, we'd like to reclaim them once
> there is memory pressure. Also it might be unfair reclaiming MADV_FREE
> pages always before used once file pages and we definitively want to
> reclaim the pages before other anonymous and file pages.
> 
> To speed up MADV_FREE pages reclaim, we put the pages into
> LRU_INACTIVE_FILE list. The rationale is LRU_INACTIVE_FILE list is tiny
> nowadays and should be full of used once file pages. Reclaiming
> MADV_FREE pages will not have much interfere of anonymous and active
> file pages. And the inactive file pages and MADV_FREE pages will be
> reclaimed according to their age, so we don't reclaim too many MADV_FREE
> pages too. Putting the MADV_FREE pages into LRU_INACTIVE_FILE_LIST also
> means we can reclaim the pages without swap support. This idea is
> suggested by Johannes.
> 
> This patch doesn't move MADV_FREE pages to LRU_INACTIVE_FILE list yet to
> avoid bisect failure, next patch will do it.
> 
> The patch is based on Minchan's original patch.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@techsingularity.net>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Shaohua Li <shli@fb.com>

This patch doesn't address I pointed out in v4.

https://marc.info/?i=20170224233752.GB4635%40bbox

Let's discuss it if you still are against.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
