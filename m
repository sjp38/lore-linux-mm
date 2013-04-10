Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id DEB026B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 10:14:50 -0400 (EDT)
Date: Wed, 10 Apr 2013 15:14:45 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/10] Reduce system disruption due to kswapd V2
Message-ID: <20130410141445.GD3710@suse.de>
References: <1365505625-9460-1-git-send-email-mgorman@suse.de>
 <0000013defd666bf-213d70fc-dfbd-4a50-82ed-e9f4f7391b55-000000@email.amazonses.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <0000013defd666bf-213d70fc-dfbd-4a50-82ed-e9f4f7391b55-000000@email.amazonses.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jiri Slaby <jslaby@suse.cz>, Valdis Kletnieks <Valdis.Kletnieks@vt.edu>, Rik van Riel <riel@redhat.com>, Zlatko Calusic <zcalusic@bitsync.net>, Johannes Weiner <hannes@cmpxchg.org>, dormando <dormando@rydia.net>, Satoru Moriya <satoru.moriya@hds.com>, Michal Hocko <mhocko@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Apr 09, 2013 at 05:27:18PM +0000, Christoph Lameter wrote:
> One additional measure that may be useful is to make kswapd prefer one
> specific processor on a socket. Two benefits arise from that:
> 
> 1. Better use of cpu caches and therefore higher speed, less
> serialization.
> 

Considering the volume of pages that kswapd can scan when it's active
I would expect that it trashes its cache anyway. The L1 cache would be
flushed after scanning struct pages for just a few MB of memory.

> 2. Reduction of the disturbances to one processor.
> 

I've never checked it but I would have expected kswapd to stay on the
same processor for significant periods of time. Have you experienced
problems where kswapd bounces around on CPUs within a node causing
workload disruption?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
