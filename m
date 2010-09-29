Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 199B46B004A
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 10:34:13 -0400 (EDT)
Date: Wed, 29 Sep 2010 09:34:09 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: zone state overhead
In-Reply-To: <20100929141730.GB14204@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1009290930360.1538@router.home>
References: <20100928050801.GA29021@sli10-conroe.sh.intel.com> <alpine.DEB.2.00.1009280736020.4144@router.home> <20100928133059.GL8187@csn.ul.ie> <alpine.DEB.2.00.1009282024570.31551@chino.kir.corp.google.com> <20100929100307.GA14204@csn.ul.ie>
 <alpine.DEB.2.00.1009290736280.30777@router.home> <20100929141730.GB14204@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: David Rientjes <rientjes@google.com>, Shaohua Li <shaohua.li@intel.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 29 Sep 2010, Mel Gorman wrote:

> > Updating the threshold also is expensive.
>
> Even if it's moved to a read-mostly part of the zone such as after
> lowmem_reserve?

The threshold is stored in the hot part of the per cpu page structure.

> > I thought more along the lines
> > of reducing the threshold for good if the VM runs into reclaim trouble
> > because of too high fuzziness in the counters.
> >
>
> That would be unfortunate as it would only take trouble to happen once
> for performance to be impaired for the remaining uptime of the machine.

Reclaim also impairs performance and inaccurate counters may cause
unnecessary reclaim. Ultimately this is a tradeoff. The current thresholds
were calculated so that there will be zero impact even for very large
configurations where all processors continual page fault. I think we have
some leeway to go lower there. The tuning situation was a bit extreme.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
