Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7B01E6B0261
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 09:56:27 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id m203so89087795wma.2
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 06:56:27 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 199si82085455wmi.91.2017.01.05.06.56.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Jan 2017 06:56:26 -0800 (PST)
Date: Thu, 5 Jan 2017 14:56:23 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 4/7] mm, vmscan: show LRU name in mm_vmscan_lru_isolate
 tracepoint
Message-ID: <20170105145623.h7jbgke2ij5opsvz@suse.de>
References: <20170104101942.4860-1-mhocko@kernel.org>
 <20170104101942.4860-5-mhocko@kernel.org>
 <20170105060458.GC24371@bbox>
 <20170105101613.GG21618@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170105101613.GG21618@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, Jan 05, 2017 at 11:16:13AM +0100, Michal Hocko wrote:
> > > diff --git a/include/trace/events/vmscan.h b/include/trace/events/vmscan.h
> > > index 36c999f806bf..7ec59e0432c4 100644
> > > --- a/include/trace/events/vmscan.h
> > > +++ b/include/trace/events/vmscan.h
> > > @@ -277,9 +277,9 @@ TRACE_EVENT(mm_vmscan_lru_isolate,
> > >  		unsigned long nr_skipped,
> > >  		unsigned long nr_taken,
> > >  		isolate_mode_t isolate_mode,
> > > -		int file),
> > > +		int lru),
> > 
> > It may break trace-vmscan-postprocess.pl. Other than that,
> 
> I wasn't aware of the script. And you are right it will break it. The
> following should fix it. Btw. shrink_inactive_list tracepoint changes
> will to be synced as well. I do not speak perl much but the following
> should just work (untested yet).

It's also optional to remove them. When those were first merged, it was
done to illustrate how multiple tracepoints can be used to aggregate
tracepoint information. They are better ways of gathering the same class
of information. They are of historical interest but not as fully supported
scripts that can never break.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
