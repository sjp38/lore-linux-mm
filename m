Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D49A46B004A
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 11:14:21 -0400 (EDT)
Date: Wed, 29 Sep 2010 09:52:50 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: zone state overhead
In-Reply-To: <20100929144159.GC14204@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1009290950350.1999@router.home>
References: <20100928050801.GA29021@sli10-conroe.sh.intel.com> <alpine.DEB.2.00.1009280736020.4144@router.home> <20100928133059.GL8187@csn.ul.ie> <alpine.DEB.2.00.1009282024570.31551@chino.kir.corp.google.com> <20100929100307.GA14204@csn.ul.ie>
 <alpine.DEB.2.00.1009290736280.30777@router.home> <20100929141730.GB14204@csn.ul.ie> <alpine.DEB.2.00.1009290930360.1538@router.home> <20100929144159.GC14204@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: David Rientjes <rientjes@google.com>, Shaohua Li <shaohua.li@intel.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 29 Sep 2010, Mel Gorman wrote:

> > The threshold is stored in the hot part of the per cpu page structure.
> >
>
> And the consequences of moving it? In terms of moving, it would probably
> work out better to move percpu_drift_mark after the lowmem_reserve and
> put the threshold after it so they're at least similarly hot across
> CPUs.

If you move it then the cache footprint of the vm stat functions (which
need to access the threshold for each access!) will increase and the
performance sink dramatically. I tried to avoid placing the threshold
there when I developed that approach but it always caused a dramatic
regression under heavy load.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
