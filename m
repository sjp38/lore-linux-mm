Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 2D6B16B0038
	for <linux-mm@kvack.org>; Fri, 30 Dec 2016 04:36:59 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id c85so34908213wmi.6
        for <linux-mm@kvack.org>; Fri, 30 Dec 2016 01:36:59 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id yr4si61542378wjc.210.2016.12.30.01.36.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Dec 2016 01:36:57 -0800 (PST)
Date: Fri, 30 Dec 2016 10:36:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/7] vm, vmscan: enahance vmscan tracepoints
Message-ID: <20161230093654.GC13301@dhcp22.suse.cz>
References: <20161228153032.10821-1-mhocko@kernel.org>
 <20161230091117.nkxn3bnhle3bofhw@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161230091117.nkxn3bnhle3bofhw@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Fri 30-12-16 09:11:17, Mel Gorman wrote:
> On Wed, Dec 28, 2016 at 04:30:25PM +0100, Michal Hocko wrote:
> > Hi,
> > while debugging [1] I've realized that there is some room for
> > improvements in the tracepoints set we offer currently. I had hard times
> > to make any conclusion from the existing ones. The resulting problem
> > turned out to be active list aging [2] and we are missing at least two
> > tracepoints to debug such a problem.
> > 
> > Some existing tracepoints could export more information to see _why_ the
> > reclaim progress cannot be made not only _how much_ we could reclaim.
> > The later could be seen quite reasonably from the vmstat counters
> > already. It can be argued that we are showing too many implementation
> > details in those tracepoints but I consider them way too lowlevel
> > already to be usable by any kernel independent userspace. I would be
> > _really_ surprised if anything but debugging tools have used them.
> > 
> > Any feedback is highly appreciated.
> > 
> 
> There is some minor overhead introduced in some paths regardless of
> whether the tracepoints are active or not but I suspect it's negligible
> in the context of the overhead of reclaim in general so;

I will work on improving some of them. E.g. I've dropped the change to
free_hot_cold_page_list because that is indeed a hot path but other than
that there shouldn't be any even medium hot path which should see any
overhead I can see. If you are aware of any, please let me know and I
will think about how to improve it.
 
> Acked-by: Mel Gorman <mgorman@suse.de>

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
