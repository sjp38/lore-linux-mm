Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 502016B0038
	for <linux-mm@kvack.org>; Fri, 30 Dec 2016 04:11:21 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id iq1so36504748wjb.1
        for <linux-mm@kvack.org>; Fri, 30 Dec 2016 01:11:21 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ho7si61489649wjb.275.2016.12.30.01.11.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Dec 2016 01:11:19 -0800 (PST)
Date: Fri, 30 Dec 2016 09:11:17 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/7] vm, vmscan: enahance vmscan tracepoints
Message-ID: <20161230091117.nkxn3bnhle3bofhw@suse.de>
References: <20161228153032.10821-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20161228153032.10821-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, Dec 28, 2016 at 04:30:25PM +0100, Michal Hocko wrote:
> Hi,
> while debugging [1] I've realized that there is some room for
> improvements in the tracepoints set we offer currently. I had hard times
> to make any conclusion from the existing ones. The resulting problem
> turned out to be active list aging [2] and we are missing at least two
> tracepoints to debug such a problem.
> 
> Some existing tracepoints could export more information to see _why_ the
> reclaim progress cannot be made not only _how much_ we could reclaim.
> The later could be seen quite reasonably from the vmstat counters
> already. It can be argued that we are showing too many implementation
> details in those tracepoints but I consider them way too lowlevel
> already to be usable by any kernel independent userspace. I would be
> _really_ surprised if anything but debugging tools have used them.
> 
> Any feedback is highly appreciated.
> 

There is some minor overhead introduced in some paths regardless of
whether the tracepoints are active or not but I suspect it's negligible
in the context of the overhead of reclaim in general so;

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
