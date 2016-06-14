Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8B03E6B007E
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 10:41:06 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id j6so4503517lfb.1
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 07:41:06 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id c10si8176968wjb.241.2016.06.14.07.41.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 14 Jun 2016 07:41:05 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id C752398FFB
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 14:41:04 +0000 (UTC)
Date: Tue, 14 Jun 2016 15:41:03 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 02/27] mm, vmscan: Move lru_lock to the node
Message-ID: <20160614144103.GB1868@techsingularity.net>
References: <1465495483-11855-1-git-send-email-mgorman@techsingularity.net>
 <1465495483-11855-3-git-send-email-mgorman@techsingularity.net>
 <575AED3E.3090705@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <575AED3E.3090705@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>

On Fri, Jun 10, 2016 at 06:39:26PM +0200, Vlastimil Babka wrote:
> > @@ -5944,10 +5944,10 @@ static void __paginginit free_area_init_core(struct pglist_data *pgdat)
> >  		zone->min_slab_pages = (freesize * sysctl_min_slab_ratio) / 100;
> >  #endif
> >  		zone->name = zone_names[j];
> > +		zone->zone_pgdat = pgdat;
> >  		spin_lock_init(&zone->lock);
> > -		spin_lock_init(&zone->lru_lock);
> > +		spin_lock_init(zone_lru_lock(zone));
> 
> This means the same lock will be inited MAX_NR_ZONES times. Peterz told
> me it's valid but weird. Probably better to do it just once, in case
> lockdep/lock debugging gains some checks for that?
> 

Good point and it's an easy fix.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
