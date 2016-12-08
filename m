Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 23F166B025E
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 06:06:59 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id y16so4894223wmd.6
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 03:06:59 -0800 (PST)
Received: from outbound-smtp08.blacknight.com (outbound-smtp08.blacknight.com. [46.22.139.13])
        by mx.google.com with ESMTPS id d81si12702526wmc.164.2016.12.08.03.06.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 03:06:57 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp08.blacknight.com (Postfix) with ESMTPS id 41C391C203D
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 11:06:57 +0000 (GMT)
Date: Thu, 8 Dec 2016 11:06:56 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v7
Message-ID: <20161208110656.bnkvqg73qnjkehbc@techsingularity.net>
References: <20161207101228.8128-1-mgorman@techsingularity.net>
 <1481137249.4930.59.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161207194801.krhonj7yggbedpba@techsingularity.net>
 <1481141424.4930.71.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161207211958.s3ymjva54wgakpkm@techsingularity.net>
 <20161207232531.fxqdgrweilej5gs6@techsingularity.net>
 <20161208092231.55c7eacf@redhat.com>
 <20161208091806.gzcxlerxprcjvt3l@techsingularity.net>
 <20161208114308.1c6a424f@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20161208114308.1c6a424f@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On Thu, Dec 08, 2016 at 11:43:08AM +0100, Jesper Dangaard Brouer wrote:
> > That's expected. In the initial sniff-test, I saw negligible packet loss.
> > I'm waiting to see what the full set of network tests look like before
> > doing any further adjustments.
> 
> For netperf I will not recommend adjusting the global default
> /proc/sys/net/core/rmem_default as netperf have means of adjusting this
> value from the application (which were the options you setup too low
> and just removed). I think you should keep this as the default for now
> (unless Eric says something else), as this should cover most users.
> 

Ok, the current state is that buffer sizes are only set for netperf
UDP_STREAM and only when running over a real network. The values selected
were specific to the network I had available so milage may vary.
localhost is left at the defaults.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
