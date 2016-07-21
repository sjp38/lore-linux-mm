Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5E1E96B0278
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 04:16:14 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b65so7713950wmg.0
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 01:16:14 -0700 (PDT)
Received: from outbound-smtp11.blacknight.com (outbound-smtp11.blacknight.com. [46.22.139.16])
        by mx.google.com with ESMTPS id n1si2069336wmn.46.2016.07.21.01.16.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jul 2016 01:16:13 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp11.blacknight.com (Postfix) with ESMTPS id E21171C14B0
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 09:16:12 +0100 (IST)
Date: Thu, 21 Jul 2016 09:16:11 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 5/5] mm: consider per-zone inactive ratio to deactivate
Message-ID: <20160721081611.GG10438@techsingularity.net>
References: <1469028111-1622-1-git-send-email-mgorman@techsingularity.net>
 <1469028111-1622-6-git-send-email-mgorman@techsingularity.net>
 <20160721071050.GB27554@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160721071050.GB27554@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 21, 2016 at 04:10:50PM +0900, Joonsoo Kim wrote:
> > @@ -1993,6 +1994,32 @@ static bool inactive_list_is_low(struct lruvec *lruvec, bool file)
> >  	inactive = lruvec_lru_size(lruvec, file * LRU_FILE);
> >  	active = lruvec_lru_size(lruvec, file * LRU_FILE + LRU_ACTIVE);
> >  
> > +	/*
> > +	 * For global reclaim on zone-constrained allocations, it is necessary
> > +	 * to check if rotations are required for lowmem to be reclaimed. This
> > +	 * calculates the inactive/active pages available in eligible zones.
> > +	 */
> > +	if (global_reclaim(sc)) {
> > +		struct pglist_data *pgdat = lruvec_pgdat(lruvec);
> > +		int zid;
> > +
> > +		for (zid = sc->reclaim_idx; zid < MAX_NR_ZONES; zid++) {
> 
> Should be changed to "zid = sc->reclaim_idx + 1"
> 

You're right, well spotted!

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
