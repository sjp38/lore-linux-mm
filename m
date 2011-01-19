Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3A6F18D003A
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 15:18:21 -0500 (EST)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p0JKIF7B020135
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 12:18:15 -0800
Received: from pvc30 (pvc30.prod.google.com [10.241.209.158])
	by hpaq1.eem.corp.google.com with ESMTP id p0JKICYf021931
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 19 Jan 2011 12:18:14 -0800
Received: by pvc30 with SMTP id 30so309894pvc.0
        for <linux-mm@kvack.org>; Wed, 19 Jan 2011 12:18:12 -0800 (PST)
Date: Wed, 19 Jan 2011 12:18:08 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm: fix deferred congestion timeout if preferred zone
 is not allowed
In-Reply-To: <20110119200625.GD15568@one.firstfloor.org>
Message-ID: <alpine.DEB.2.00.1101191212090.19519@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1101172108380.29048@chino.kir.corp.google.com> <AANLkTin036LNAJ053ByMRmQUnsBpRcv1s5uX1j_2c_Ds@mail.gmail.com> <alpine.DEB.2.00.1101181751420.25382@chino.kir.corp.google.com> <alpine.DEB.2.00.1101191351010.20403@router.home>
 <20110119200625.GD15568@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Christoph Lameter <cl@linux.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Wu Fengguang <fengguang.wu@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 19 Jan 2011, Andi Kleen wrote:

> cpusets didn't exist when I designed that. But the idea was that
> the kernel has a first choice ("hit") and any other node is a "miss"
> that may need investigation.  So yes I would consider cpuset config as an 
> intention too and should be counted as hit/miss.
> 

Ok, so there's no additional modification that needs to be made with the 
patch (other than perhaps some more descriptive documentation of a 
NUMA_HIT and NUMA_MISS).  When the kernel passes all zones into the page 
allocator, it's relying on cpusets to reduce that zonelist to only 
allowable nodes by using ALLOC_CPUSET.  If we can allocate from the first 
zone allowed by the cpuset, it will be treated as a hit; otherwise, it 
will be treated as a miss.  That's better than treating everything as a 
miss when the cpuset doesn't include the first node.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
