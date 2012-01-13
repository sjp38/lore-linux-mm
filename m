Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 7DF126B004F
	for <linux-mm@kvack.org>; Fri, 13 Jan 2012 13:39:28 -0500 (EST)
Date: Fri, 13 Jan 2012 19:39:26 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC][PATCH] mm: Remove NUMA_INTERLEAVE_HIT
Message-ID: <20120113183926.GL11715@one.firstfloor.org>
References: <1326380820.2442.186.camel@twins> <20120112182644.GE11715@one.firstfloor.org> <1326399227.2442.209.camel@twins> <20120112210743.GG11715@one.firstfloor.org> <20120112134045.552e2a61.akpm@linux-foundation.org> <20120112222929.GI11715@one.firstfloor.org> <alpine.DEB.2.00.1201130922460.25704@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1201130922460.25704@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Jan 13, 2012 at 09:28:20AM -0600, Christoph Lameter wrote:
> On Thu, 12 Jan 2012, Andi Kleen wrote:
> 
> > The problem is that then there will be nothing left that actually
> > tests interleaving. The numactl has caught kernel regressions in the past.
> 
> How about adding a CONFIG_NUMA_DEBUG option and have it only available
> then? I think there is no general use case.

For a few lines of code? And making it harder to test?

> > I don't think disabling useful regression tests is a good idea.
> > In contrary the kernel needs far more of them, not less.
> 
> True. Some more debugging code for the NUMA features would be appreciated
> but that does not need to be enabled by default. Lately I have become a
> bit concerned about the number of statistics we are adding. The
> per_cpu_pageset structure should not get too large.

I don't think the single counter is a problem.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
