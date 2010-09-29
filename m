Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 01DA96B004A
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 10:54:56 -0400 (EDT)
Date: Wed, 29 Sep 2010 09:54:54 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: zone state overhead
In-Reply-To: <20100929144556.GD14204@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1009290953430.1999@router.home>
References: <20100928050801.GA29021@sli10-conroe.sh.intel.com> <alpine.DEB.2.00.1009280736020.4144@router.home> <20100928133059.GL8187@csn.ul.ie> <alpine.DEB.2.00.1009282024570.31551@chino.kir.corp.google.com> <20100929100307.GA14204@csn.ul.ie>
 <alpine.DEB.2.00.1009290736280.30777@router.home> <20100929141730.GB14204@csn.ul.ie> <alpine.DEB.2.00.1009290930360.1538@router.home> <20100929144159.GC14204@csn.ul.ie> <20100929144556.GD14204@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: David Rientjes <rientjes@google.com>, Shaohua Li <shaohua.li@intel.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 29 Sep 2010, Mel Gorman wrote:

> I should be clearer here. Initially, I'm thinking the consequences of moving
> it are not terrible bad so I'm wondering if you see some problem I have not
> thought of. If the threshold value is sharing the cache line with watermark
> or lowmem_reserve, then it should still have the same hotness in the path
> we really care about (zone_watermark_ok for example) without necessarily
> needing to be part of the per-cpu structure. The real badness would be if an
> additional cache line was required due to the move but I don't think this is
> the case (but I didn't double check with pahole or the back of an envelope
> either). The line will be dirtied and cause a bounce when kswapd wakes or
> goes to sleep but this should not be a severe problem.

The critical paths for vm statistics are __inc_zone_state() and
__dec_zone_state(). Those are sprinkled all over.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
