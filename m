Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 12AA86B0005
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 11:53:04 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id qh10so192193139pac.2
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 08:53:04 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id o62si4809038pfb.55.2016.07.15.08.53.02
        for <linux-mm@kvack.org>;
        Fri, 15 Jul 2016 08:53:03 -0700 (PDT)
Date: Sat, 16 Jul 2016 00:53:02 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 3/5] mm, pagevec: Release/reacquire lru_lock on pgdat
 change
Message-ID: <20160715155302.GD8644@bbox>
References: <1468588165-12461-1-git-send-email-mgorman@techsingularity.net>
 <1468588165-12461-4-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
In-Reply-To: <1468588165-12461-4-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 15, 2016 at 02:09:23PM +0100, Mel Gorman wrote:
> With node-lru, the locking is based on the pgdat. Previously it was
> required that a pagevec drain released one zone lru_lock and acquired
> another zone lru_lock on every zone change. Now, it's only necessary if
> the node changes. The end-result is fewer lock release/acquires if the
> pages are all on the same node but in different zones.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Minchan Kim <minchan@kernel.org>

check_move_unevictable_pages could be a candidate, too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
