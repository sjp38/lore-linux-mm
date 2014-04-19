Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 914216B0031
	for <linux-mm@kvack.org>; Sat, 19 Apr 2014 07:18:59 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id b15so2290938eek.6
        for <linux-mm@kvack.org>; Sat, 19 Apr 2014 04:18:58 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 43si44479724eer.27.2014.04.19.04.18.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 19 Apr 2014 04:18:58 -0700 (PDT)
Date: Sat, 19 Apr 2014 12:18:05 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 06/16] mm: page_alloc: Calculate classzone_idx once from
 the zonelist ref
Message-ID: <20140419111805.GB4225@suse.de>
References: <1397832643-14275-1-git-send-email-mgorman@suse.de>
 <1397832643-14275-7-git-send-email-mgorman@suse.de>
 <20140418180309.GC29210@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140418180309.GC29210@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Fri, Apr 18, 2014 at 02:03:09PM -0400, Johannes Weiner wrote:
> On Fri, Apr 18, 2014 at 03:50:33PM +0100, Mel Gorman wrote:
> > @@ -2463,7 +2462,7 @@ static inline struct page *
> >  __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >  	struct zonelist *zonelist, enum zone_type high_zoneidx,
> >  	nodemask_t *nodemask, struct zone *preferred_zone,
> > -	int migratetype)
> > +	int classzone_idx, int migratetype)
> >  {
> >  	const gfp_t wait = gfp_mask & __GFP_WAIT;
> >  	struct page *page = NULL;
> 
> There is another potential update of preferred_zone in this function
> after which the classzone_idx should probably be refreshed:
> 
> 	/*
> 	 * Find the true preferred zone if the allocation is unconstrained by
> 	 * cpusets.
> 	 */
> 	if (!(alloc_flags & ALLOC_CPUSET) && !nodemask)
> 		first_zones_zonelist(zonelist, high_zoneidx, NULL,
> 					&preferred_zone);

Thanks, I'll fix it up for v2.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
