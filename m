Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1D64F6B004A
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 10:17:45 -0400 (EDT)
Date: Wed, 29 Sep 2010 15:17:30 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: zone state overhead
Message-ID: <20100929141730.GB14204@csn.ul.ie>
References: <20100928050801.GA29021@sli10-conroe.sh.intel.com> <alpine.DEB.2.00.1009280736020.4144@router.home> <20100928133059.GL8187@csn.ul.ie> <alpine.DEB.2.00.1009282024570.31551@chino.kir.corp.google.com> <20100929100307.GA14204@csn.ul.ie> <alpine.DEB.2.00.1009290736280.30777@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1009290736280.30777@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: David Rientjes <rientjes@google.com>, Shaohua Li <shaohua.li@intel.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 29, 2010 at 09:12:25AM -0500, Christoph Lameter wrote:
> On Wed, 29 Sep 2010, Mel Gorman wrote:
> 
> > Alternatively we could revisit Christoph's suggestion of modifying
> > stat_threshold when under pressure instead of zone_page_state_snapshot. Maybe
> > by temporarily stat_threshold when kswapd is awake to a per-zone value
> > such that
> >
> > zone->low + threshold*nr_online_cpus < high
> 
> Updating the threshold also is expensive.

Even if it's moved to a read-mostly part of the zone such as after
lowmem_reserve?

> I thought more along the lines
> of reducing the threshold for good if the VM runs into reclaim trouble
> because of too high fuzziness in the counters.
> 

That would be unfortunate as it would only take trouble to happen once
for performance to be impaired for the remaining uptime of the machine.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
