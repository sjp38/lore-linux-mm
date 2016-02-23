Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 3968C6B0005
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 14:03:51 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id g62so214507234wme.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 11:03:51 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ik8si44699641wjb.229.2016.02.23.11.03.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Feb 2016 11:03:50 -0800 (PST)
Date: Tue, 23 Feb 2016 11:03:46 -0800
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 06/27] mm, vmscan: Begin reclaiming pages on a per-node
 basis
Message-ID: <20160223190346.GG13816@cmpxchg.org>
References: <1456239890-20737-1-git-send-email-mgorman@techsingularity.net>
 <1456239890-20737-7-git-send-email-mgorman@techsingularity.net>
 <20160223185722.GF13816@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160223185722.GF13816@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>

On Tue, Feb 23, 2016 at 10:57:22AM -0800, Johannes Weiner wrote:
> > @@ -2558,16 +2579,12 @@ static void shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
> >  		sc->gfp_mask |= __GFP_HIGHMEM;
> >  
> >  	for_each_zone_zonelist_nodemask(zone, z, zonelist,
> > -					requested_highidx, sc->nodemask) {
> 
> It's unfortunate that we start with the lowest zone here. For Normal
> allocations, the most common allocations, this will always have two
> full shrink_node() rounds that skip over everything >DMA in the first,
> then over everything >DMA32 in the second, even though all pages on
> the node are valid reclaim candidates for that allocation.

Nevermind, I'm confused about zonelist ordering. It starts with the
highest indexed zones.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
