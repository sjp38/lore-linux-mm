Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id A5FB56B0005
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 04:26:26 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id m101so7332477ioi.0
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 01:26:26 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id r64si195911iod.174.2016.07.26.01.26.25
        for <linux-mm@kvack.org>;
        Tue, 26 Jul 2016 01:26:25 -0700 (PDT)
Date: Tue, 26 Jul 2016 17:27:01 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC] mm: bail out in shrin_inactive_list
Message-ID: <20160726082701.GA9950@bbox>
References: <1469433119-1543-1-git-send-email-minchan@kernel.org>
 <20160725092909.GV11400@suse.de>
 <20160726012157.GA11651@bbox>
 <20160726074650.GW11400@suse.de>
MIME-Version: 1.0
In-Reply-To: <20160726074650.GW11400@suse.de>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov@virtuozzo.com>

On Tue, Jul 26, 2016 at 08:46:50AM +0100, Mel Gorman wrote:
> On Tue, Jul 26, 2016 at 10:21:57AM +0900, Minchan Kim wrote:
> > > > I believe proper fix is to modify get_scan_count. IOW, I think
> > > > we should introduce lruvec_reclaimable_lru_size with proper
> > > > classzone_idx but I don't know how we can fix it with memcg
> > > > which doesn't have zone stat now. should introduce zone stat
> > > > back to memcg? Or, it's okay to ignore memcg?
> > > > 
> > > 
> > > I think it's ok to ignore memcg in this case as a memcg shrink is often
> > > going to be for pages that can use highmem anyway.
> > 
> > So, you mean it's okay to ignore kmemcg case?
> > If memcg guys agree it, I want to make get_scan_count consider
> > reclaimable lru size under the reclaim constraint, instead.
> > 
> 
> For now, I believe yet. My understanding is that the primary use cases
> for kmemcg is systems running large numbers of containers. It consider
> it extremely unlikely that large 32-bit systems are being used for large
> numbers of containers and require usage of kmemcg.

Okay, Then how about this?
I didn't test it but I guess it should work.
