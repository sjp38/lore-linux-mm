Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 9BA806B0009
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 05:21:52 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id c200so261912596wme.0
        for <linux-mm@kvack.org>; Wed, 24 Feb 2016 02:21:52 -0800 (PST)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id wm7si2781580wjc.125.2016.02.24.02.21.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Feb 2016 02:21:51 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id 05E721C1EB4
	for <linux-mm@kvack.org>; Wed, 24 Feb 2016 10:21:51 +0000 (GMT)
Date: Wed, 24 Feb 2016 10:21:49 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 06/27] mm, vmscan: Begin reclaiming pages on a per-node
 basis
Message-ID: <20160224102149.GS2854@techsingularity.net>
References: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
 <1456239890-20737-7-git-send-email-mgorman@techsingularity.net>
 <20160223185722.GF13816@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160223185722.GF13816@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Tue, Feb 23, 2016 at 10:57:22AM -0800, Johannes Weiner wrote:
> On Tue, Feb 23, 2016 at 03:04:29PM +0000, Mel Gorman wrote:
> > @@ -2428,10 +2448,11 @@ static bool shrink_zone(struct zone *zone, struct scan_control *sc,
> >  			reclaimed = sc->nr_reclaimed;
> >  			scanned = sc->nr_scanned;
> >  
> > +			sc->reclaim_idx = reclaim_idx;
> >  			shrink_zone_memcg(zone, memcg, sc, &lru_pages);
> >  			zone_lru_pages += lru_pages;
> 
> The setting of sc->reclaim_idx is unexpected here. Why not set it in
> the caller and eliminate the reclaim_idx parameter?
> 

Initially because it was easier to develop the patch for but it's good
either way. I updated this patch and handled the conflicts. It's now set
in the callers.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
