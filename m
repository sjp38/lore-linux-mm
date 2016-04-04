Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f180.google.com (mail-lb0-f180.google.com [209.85.217.180])
	by kanga.kvack.org (Postfix) with ESMTP id 599356B0005
	for <linux-mm@kvack.org>; Mon,  4 Apr 2016 05:42:16 -0400 (EDT)
Received: by mail-lb0-f180.google.com with SMTP id vo2so152281335lbb.1
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 02:42:16 -0700 (PDT)
Received: from mail-lb0-f195.google.com (mail-lb0-f195.google.com. [209.85.217.195])
        by mx.google.com with ESMTPS id rl2si15430239lbb.151.2016.04.04.02.42.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Apr 2016 02:42:15 -0700 (PDT)
Received: by mail-lb0-f195.google.com with SMTP id bc4so21012555lbc.0
        for <linux-mm@kvack.org>; Mon, 04 Apr 2016 02:42:14 -0700 (PDT)
Date: Mon, 4 Apr 2016 11:42:13 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm, oom: rework oom detection
Message-ID: <20160404094213.GB13463@dhcp22.suse.cz>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <1450203586-10959-2-git-send-email-mhocko@kernel.org>
 <20160404082343.GD6610@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160404082343.GD6610@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 04-04-16 11:23:43, Vladimir Davydov wrote:
> On Tue, Dec 15, 2015 at 07:19:44PM +0100, Michal Hocko wrote:
> ...
> > @@ -2592,17 +2589,10 @@ static bool shrink_zones(struct zonelist *zonelist, struct scan_control *sc)
> >  						&nr_soft_scanned);
> >  			sc->nr_reclaimed += nr_soft_reclaimed;
> >  			sc->nr_scanned += nr_soft_scanned;
> > -			if (nr_soft_reclaimed)
> > -				reclaimable = true;
> >  			/* need some check for avoid more shrink_zone() */
> >  		}
> >  
> > -		if (shrink_zone(zone, sc, zone_idx(zone) == classzone_idx))
> > -			reclaimable = true;
> > -
> > -		if (global_reclaim(sc) &&
> > -		    !reclaimable && zone_reclaimable(zone))
> > -			reclaimable = true;
> > +		shrink_zone(zone, sc, zone_idx(zone));
> 
> Shouldn't it be
> 
> 		shrink_zone(zone, sc, zone_idx(zone) == classzone_idx);
> 
> ?

I cannot remember the reason why I have removed it so it is more likely
this was unintentional. Thanks for catching this. I will fold it into
the original patch before I repost the full series (this week
hopefully).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
