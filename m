Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id C541E6B0253
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 10:17:40 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id qs7so67455323wjc.4
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 07:17:40 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bl4si45072504wjb.200.2017.01.05.07.17.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Jan 2017 07:17:39 -0800 (PST)
Date: Thu, 5 Jan 2017 16:17:37 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/7] mm, vmscan: show LRU name in mm_vmscan_lru_isolate
 tracepoint
Message-ID: <20170105151737.GU21618@dhcp22.suse.cz>
References: <20170104101942.4860-1-mhocko@kernel.org>
 <20170104101942.4860-5-mhocko@kernel.org>
 <20170105060458.GC24371@bbox>
 <20170105101613.GG21618@dhcp22.suse.cz>
 <20170105145623.h7jbgke2ij5opsvz@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170105145623.h7jbgke2ij5opsvz@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 05-01-17 14:56:23, Mel Gorman wrote:
> On Thu, Jan 05, 2017 at 11:16:13AM +0100, Michal Hocko wrote:
> > > > diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
> > > > index 36c999f806bf..7ec59e0432c4 100644
> > > > --- a/include/trace/events/vmscan.h
> > > > +++ b/include/trace/events/vmscan.h
> > > > @@ -277,9 +277,9 @@ TRACE_EVENT(mm_vmscan_lru_isolate,
> > > >  		unsigned long nr_skipped,
> > > >  		unsigned long nr_taken,
> > > >  		isolate_mode_t isolate_mode,
> > > > -		int file),
> > > > +		int lru),
> > > 
> > > It may break trace-vmscan-postprocess.pl. Other than that,
> > 
> > I wasn't aware of the script. And you are right it will break it. The
> > following should fix it. Btw. shrink_inactive_list tracepoint changes
> > will to be synced as well. I do not speak perl much but the following
> > should just work (untested yet).
> 
> It's also optional to remove them. When those were first merged, it was
> done to illustrate how multiple tracepoints can be used to aggregate
> tracepoint information. They are better ways of gathering the same class
> of information. They are of historical interest but not as fully supported
> scripts that can never break.

Yeah, that was my understanding and why I didn't consider it a priority.
But it seemed like an easy thing to fix even with my anti-perl mindset.
Here is the full patch (untested)
---
