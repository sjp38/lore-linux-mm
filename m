Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id D544B6B0005
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 12:20:37 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id o80so62055257wme.1
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 09:20:37 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id u84si15664089wmg.19.2016.07.18.09.20.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jul 2016 09:20:36 -0700 (PDT)
Date: Mon, 18 Jul 2016 12:20:31 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/5] mm, pagevec: Release/reacquire lru_lock on pgdat
 change
Message-ID: <20160718162031.GF16465@cmpxchg.org>
References: <1468588165-12461-1-git-send-email-mgorman@techsingularity.net>
 <1468588165-12461-4-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1468588165-12461-4-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 15, 2016 at 02:09:23PM +0100, Mel Gorman wrote:
> With node-lru, the locking is based on the pgdat. Previously it was
> required that a pagevec drain released one zone lru_lock and acquired
> another zone lru_lock on every zone change. Now, it's only necessary if
> the node changes. The end-result is fewer lock release/acquires if the
> pages are all on the same node but in different zones.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

This could make quite a difference on some workloads, from a whole
series perspective, when considering that we had the round robin fair
zone allocator on top of this. Page batches that span multiple nodes
on the other hand are much less likely.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
