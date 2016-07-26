Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9EC296B0005
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 03:46:55 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id p129so1796944wmp.3
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 00:46:55 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f3si18589130wje.178.2016.07.26.00.46.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Jul 2016 00:46:54 -0700 (PDT)
Date: Tue, 26 Jul 2016 08:46:50 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [RFC] mm: bail out in shrin_inactive_list
Message-ID: <20160726074650.GW11400@suse.de>
References: <1469433119-1543-1-git-send-email-minchan@kernel.org>
 <20160725092909.GV11400@suse.de>
 <20160726012157.GA11651@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160726012157.GA11651@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov@virtuozzo.com>

On Tue, Jul 26, 2016 at 10:21:57AM +0900, Minchan Kim wrote:
> > > I believe proper fix is to modify get_scan_count. IOW, I think
> > > we should introduce lruvec_reclaimable_lru_size with proper
> > > classzone_idx but I don't know how we can fix it with memcg
> > > which doesn't have zone stat now. should introduce zone stat
> > > back to memcg? Or, it's okay to ignore memcg?
> > > 
> > 
> > I think it's ok to ignore memcg in this case as a memcg shrink is often
> > going to be for pages that can use highmem anyway.
> 
> So, you mean it's okay to ignore kmemcg case?
> If memcg guys agree it, I want to make get_scan_count consider
> reclaimable lru size under the reclaim constraint, instead.
> 

For now, I believe yet. My understanding is that the primary use cases
for kmemcg is systems running large numbers of containers. It consider
it extremely unlikely that large 32-bit systems are being used for large
numbers of containers and require usage of kmemcg.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
