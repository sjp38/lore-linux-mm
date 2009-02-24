Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 155396B00CA
	for <linux-mm@kvack.org>; Tue, 24 Feb 2009 12:55:50 -0500 (EST)
Date: Tue, 24 Feb 2009 17:55:44 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 08/19] Simplify the check on whether cpusets are a
	factor or not
Message-ID: <20090224175544.GD5333@csn.ul.ie>
References: <1235477835-14500-1-git-send-email-mel@csn.ul.ie> <1235477835-14500-9-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0902241226280.32227@qirst.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0902241226280.32227@qirst.com>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 24, 2009 at 12:27:02PM -0500, Christoph Lameter wrote:
> On Tue, 24 Feb 2009, Mel Gorman wrote:
> 
> > @@ -1420,8 +1429,8 @@ zonelist_scan:
> >  		if (NUMA_BUILD && zlc_active &&
> >  			!zlc_zone_worth_trying(zonelist, z, allowednodes))
> >  				continue;
> > -		if ((alloc_flags & ALLOC_CPUSET) &&
> > -			!cpuset_zone_allowed_softwall(zone, gfp_mask))
> > +		if (alloc_cpuset)
> > +			if (!cpuset_zone_allowed_softwall(zone, gfp_mask))
> >  				goto try_next_zone;
> 
> Hmmm... Why remove the && here? Looks more confusing to me.
> 

At the time, just because it was what I was splitting out. Chances are
it makes no difference to the assembly. I'll double check and if not,
switch it back.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
