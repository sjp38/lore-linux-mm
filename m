Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 051416B0005
	for <linux-mm@kvack.org>; Fri, 15 Jul 2016 11:50:57 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id w207so189607468oiw.1
        for <linux-mm@kvack.org>; Fri, 15 Jul 2016 08:50:57 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id o138si1658088ioo.211.2016.07.15.08.50.55
        for <linux-mm@kvack.org>;
        Fri, 15 Jul 2016 08:50:56 -0700 (PDT)
Date: Sat, 16 Jul 2016 00:50:53 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/5] mm, vmscan: avoid passing in classzone_idx
 unnecessarily to compaction_ready -fix
Message-ID: <20160715155053.GC8644@bbox>
References: <1468588165-12461-1-git-send-email-mgorman@techsingularity.net>
 <1468588165-12461-3-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
In-Reply-To: <1468588165-12461-3-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 15, 2016 at 02:09:22PM +0100, Mel Gorman wrote:
> As pointed out by Vlastimil, there is a redundant check in shrink_zones
> since commit "mm, vmscan: avoid passing in classzone_idx unnecessarily to
> compaction_ready".  The zonelist iterator only returns zones that already
> meet the requirements of the allocation request.
> 
> This is a fix to the mmotm patch
> mm-vmscan-avoid-passing-in-classzone_idx-unnecessarily-to-compaction_ready.patch
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
Acked-by: Minchan Kim <minchan@kernel.org>

Just a Nit:
It seems there is another redundant check in there.

shrink_zones
..
        for_each_zone_zonelist_nodemask(zone, z, zonelist,
                                        sc->reclaim_idx, sc->nodemask) {
                if (!populated_zone(zone)) <==
                        continue;

Of course, it's not your fault but it would be a good chance to
remove such trivial thing :)
If I don't miss something, I hope piggyback on this patch. Andrew?
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
