Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 99C90828E1
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 11:47:04 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id e7so155757475lfe.0
        for <linux-mm@kvack.org>; Fri, 05 Aug 2016 08:47:04 -0700 (PDT)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id tl19si18143278wjb.46.2016.08.05.04.55.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 05 Aug 2016 04:55:28 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id 8E23998CF4
	for <linux-mm@kvack.org>; Fri,  5 Aug 2016 11:55:28 +0000 (UTC)
Date: Fri, 5 Aug 2016 12:55:26 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 03/34] mm, vmscan: move LRU lists to node
Message-ID: <20160805115526.GS2799@techsingularity.net>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-4-git-send-email-mgorman@techsingularity.net>
 <CAAG0J9_k3edxDzqpEjt2BqqZXMW4PVj7BNUBAk6TWtw3Zh_oMg@mail.gmail.com>
 <20160805084115.GO2799@techsingularity.net>
 <20160805105256.GH19514@jhogan-linux.le.imgtec.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160805105256.GH19514@jhogan-linux.le.imgtec.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Hogan <james.hogan@imgtec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, metag <linux-metag@vger.kernel.org>

On Fri, Aug 05, 2016 at 11:52:57AM +0100, James Hogan wrote:
> > What's surprising is that it worked for the zone stats as it appears
> > that calling zone_reclaimable() from that context should also have
> > broken. Did anything change recently that would have avoided the
> > zone->pageset dereference in zone_reclaimable() before?
> 
> It appears that zone_pcp_init() was already setting zone->pageset to
> &boot_pageset, via paging_init():
> 

/me slaps self

Of course.

> > The easiest option would be to not call show_mem from arch code until
> > after the pagesets are setup.
> 
> Since no other arches seem to do show_mem earily during boot like metag,
> and doing so doesn't really add much value, I'm happy to remove it
> anyway.
> 

Thanks. Can I assume you'll merge such a patch or should I roll one?

> However could your change break other things and need fixing anyway?
> 

Not that I'm aware of. There would have to be a node-based stat that has
meaning that early in boot to have an effect. If one happened to added
then it would need fixing but until then the complexity is unnecessary.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
