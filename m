Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 43E096B0253
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 20:42:21 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 75so292083842pgf.3
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 17:42:21 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id h13si3259695plk.279.2017.01.25.17.42.19
        for <linux-mm@kvack.org>;
        Wed, 25 Jan 2017 17:42:20 -0800 (PST)
Date: Thu, 26 Jan 2017 10:42:18 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 4/5] mm: vmscan: only write dirty pages that the scanner
 has seen twice
Message-ID: <20170126014218.GD21211@bbox>
References: <20170123181641.23938-1-hannes@cmpxchg.org>
 <20170123181641.23938-5-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170123181641.23938-5-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, Jan 23, 2017 at 01:16:40PM -0500, Johannes Weiner wrote:
> Dirty pages can easily reach the end of the LRU while there are still
> clean pages to reclaim around. Don't let kswapd write them back just
> because there are a lot of them. It costs more CPU to find the clean
> pages, but that's almost certainly better than to disrupt writeback
> from the flushers with LRU-order single-page writes from reclaim. And
> the flushers have been woken up by that point, so we spend IO capacity
> on flushing and CPU capacity on finding the clean cache.
> 
> Only start writing dirty pages if they have cycled around the LRU
> twice now and STILL haven't been queued on the IO device. It's
> possible that the dirty pages are so sparsely distributed across
> different bdis, inodes, memory cgroups, that the flushers take forever
> to get to the ones we want reclaimed. Once we see them twice on the
> LRU, we know that's the quicker way to find them, so do LRU writeback.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Acked-by: Minchan Kim <minchan@kernel.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
