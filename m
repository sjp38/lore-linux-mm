Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6D01F6B0038
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 05:09:02 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id v77so44029511wmv.5
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 02:09:02 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v21si1346049wra.330.2017.01.26.02.09.01
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Jan 2017 02:09:01 -0800 (PST)
Date: Thu, 26 Jan 2017 10:08:04 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 4/5] mm: vmscan: only write dirty pages that the scanner
 has seen twice
Message-ID: <20170126100804.zrkkmghgzg2pzrtz@suse.de>
References: <20170123181641.23938-1-hannes@cmpxchg.org>
 <20170123181641.23938-5-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170123181641.23938-5-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

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

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
