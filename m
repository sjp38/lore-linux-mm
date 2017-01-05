Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8A6376B0069
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 03:25:11 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id s63so87004850wms.7
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 00:25:11 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lr1si84543717wjb.36.2017.01.05.00.25.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Jan 2017 00:25:10 -0800 (PST)
Subject: Re: [PATCH 0/7 v2] vm, vmscan: enahance vmscan tracepoints
References: <20170104101942.4860-1-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <6fc43646-8ae5-aa54-6fe0-8503d50ef6c8@suse.cz>
Date: Thu, 5 Jan 2017 09:25:07 +0100
MIME-Version: 1.0
In-Reply-To: <20170104101942.4860-1-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On 01/04/2017 11:19 AM, Michal Hocko wrote:
> Hi,
> this is the second version of the patchset [1]. I hope I've addressed all
> the review feedback.
> 
> While debugging [2] I've realized that there is some room for
> improvements in the tracepoints set we offer currently. I had hard times
> to make any conclusion from the existing ones. The resulting problem
> turned out to be active list aging [3] and we are missing at least two
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

When patch-specific feedback is addressed, then for the whole series:

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> [1] http://lkml.kernel.org/r/20161228153032.10821-1-mhocko@kernel.org
> [2] http://lkml.kernel.org/r/20161215225702.GA27944@boerne.fritz.box
> [3] http://lkml.kernel.org/r/20161223105157.GB23109@dhcp22.suse.cz
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
