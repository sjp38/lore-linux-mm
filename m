Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id B80936B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 01:47:52 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id c73so279908917pfb.7
        for <linux-mm@kvack.org>; Mon, 16 Jan 2017 22:47:52 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id f3si23983451pld.153.2017.01.16.22.47.51
        for <linux-mm@kvack.org>;
        Mon, 16 Jan 2017 22:47:52 -0800 (PST)
Date: Tue, 17 Jan 2017 15:47:48 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC PATCH 1/2] mm, vmscan: consider eligible zones in
 get_scan_count
Message-ID: <20170117064747.GB9812@blaptop>
References: <20170110125552.4170-1-mhocko@kernel.org>
 <20170110125552.4170-2-mhocko@kernel.org>
 <20170113091804.GE25212@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170113091804.GE25212@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Fri, Jan 13, 2017 at 10:18:05AM +0100, Michal Hocko wrote:
> On Tue 10-01-17 13:55:51, Michal Hocko wrote:
> [...]
> > @@ -2280,7 +2306,7 @@ static void get_scan_count(struct lruvec *lruvec, struct mem_cgroup *memcg,
> >  			unsigned long size;
> >  			unsigned long scan;
> >  
> > -			size = lruvec_lru_size(lruvec, lru);
> > +			size = lruvec_lru_size_eligibe_zones(lruvec, lru, sc->reclaim_idx);
> >  			scan = size >> sc->priority;
> >  
> >  			if (!scan && pass && force_scan)
> 
> I have just come across inactive_reclaimable_pages and it seems it is
> unnecessary after this, right Minchan?

Good catch.

At that time, I also wanted to change get_scan_count to fix the problem but
be lack of report and other guys didn't want it. :-(

I'm happy to see it now.
Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
