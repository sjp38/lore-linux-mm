Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 722696B0033
	for <linux-mm@kvack.org>; Tue, 17 Jan 2017 06:13:23 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id r126so32752508wmr.2
        for <linux-mm@kvack.org>; Tue, 17 Jan 2017 03:13:23 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v204si15555427wmg.18.2017.01.17.03.13.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Jan 2017 03:13:22 -0800 (PST)
Date: Tue, 17 Jan 2017 11:13:16 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/3] follow up nodereclaim for 32b fix
Message-ID: <20170117111316.6eakdx7ow6yodtf2@suse.de>
References: <20170117103702.28542-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170117103702.28542-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, Jan 17, 2017 at 11:36:59AM +0100, Michal Hocko wrote:
> Hi,
> I have previously posted this as an RFC [1] but there didn't seem to be
> any objections other than some requests to reorganize the changes in
> a slightly different way so I am reposting the series and asking for
> inclusion.
> 
> This is a follow up on top of [2]. The patch 1 cleans up the code a bit.
> I haven't seen any real issues or bug reports but conceptualy ignoring
> the maximum eligible zone in get_scan_count is wrong by definition. This
> is what patch 2 does.  Patch 3 removes inactive_reclaimable_pages
> which was a kind of hack around for the problem which should have been
> addressed at get_scan_count.
> 
> There is one more place which needs a special handling which is not
> a part of this series. too_many_isolated can get confused as well. I
> already have some preliminary work but it still needs some testing so I
> will post it separatelly.
> 
> Michal Hocko (3):
>       mm, vmscan: cleanup lru size claculations
>       mm, vmscan: consider eligible zones in get_scan_count
>       Revert "mm: bail out in shrink_inactive_list()"
> 

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
