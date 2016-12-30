Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 839DA6B0038
	for <linux-mm@kvack.org>; Thu, 29 Dec 2016 20:56:27 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id n189so614696918pga.4
        for <linux-mm@kvack.org>; Thu, 29 Dec 2016 17:56:27 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id u6si22058874plj.120.2016.12.29.17.56.26
        for <linux-mm@kvack.org>;
        Thu, 29 Dec 2016 17:56:26 -0800 (PST)
Date: Fri, 30 Dec 2016 10:56:25 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 4/7] mm, vmscan: show LRU name in mm_vmscan_lru_isolate
 tracepoint
Message-ID: <20161230015625.GB4184@bbox>
References: <20161228153032.10821-1-mhocko@kernel.org>
 <20161228153032.10821-5-mhocko@kernel.org>
 <20161229060204.GC1815@bbox>
 <20161229075649.GB29208@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161229075649.GB29208@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Thu, Dec 29, 2016 at 08:56:49AM +0100, Michal Hocko wrote:
> On Thu 29-12-16 15:02:04, Minchan Kim wrote:
> > On Wed, Dec 28, 2016 at 04:30:29PM +0100, Michal Hocko wrote:
> > > From: Michal Hocko <mhocko@suse.com>
> > > 
> > > mm_vmscan_lru_isolate currently prints only whether the LRU we isolate
> > > from is file or anonymous but we do not know which LRU this is. It is
> > > useful to know whether the list is file or anonymous as well. Change
> > > the tracepoint to show symbolic names of the lru rather.
> > > 
> > > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > 
> > Not exactly same with this but idea is almost same.
> > I used almost same tracepoint to investigate agging(i.e., deactivating) problem
> > in 32b kernel with node-lru.
> > It was enough. Namely, I didn't need tracepoint in shrink_active_list like your
> > first patch.
> > Your first patch is more straightforwad and information. But as you introduced
> > this patch, I want to ask in here.
> > Isn't it enough with this patch without your first one to find a such problem?
> 
> I assume this should be a reply to
> http://lkml.kernel.org/r/20161228153032.10821-8-mhocko@kernel.org, right?

I don't know my browser says "No such Message-ID known"

> And you are right that for the particular problem it was enough to have
> a tracepoint inside inactive_list_is_low and shrink_active_list one
> wasn't really needed. On the other hand aging issues are really hard to

What kinds of aging issue? What's the problem? How such tracepoint can help?
Please describe.

> debug as well and so I think that both are useful. The first one tell us
> _why_ we do aging while the later _how_ we do that.

Solve reported problem first you already knew. It would be no doubt
to merge and then send other patches about "it might be useful" with
useful scenario.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
