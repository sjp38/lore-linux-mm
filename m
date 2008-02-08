Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m18H864W022099
	for <linux-mm@kvack.org>; Fri, 8 Feb 2008 12:08:06 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m18H863K130026
	for <linux-mm@kvack.org>; Fri, 8 Feb 2008 12:08:06 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m18H85ho002155
	for <linux-mm@kvack.org>; Fri, 8 Feb 2008 12:08:06 -0500
Date: Fri, 8 Feb 2008 09:08:05 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH 1/3] hugetlb: numafy several functions
Message-ID: <20080208170805.GD15903@us.ibm.com>
References: <20080206231558.GI3477@us.ibm.com> <1202409315.5298.65.camel@localhost> <20080207185205.GD18302@us.ibm.com> <1202489237.5346.26.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1202489237.5346.26.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: wli@holomorphy.com, agl@us.ibm.com, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 08.02.2008 [11:47:17 -0500], Lee Schermerhorn wrote:
> On Thu, 2008-02-07 at 10:52 -0800, Nishanth Aravamudan wrote:
> > On 07.02.2008 [13:35:15 -0500], Lee Schermerhorn wrote:
> > > On Wed, 2008-02-06 at 15:15 -0800, Nishanth Aravamudan wrote:
> > > > hugetlb: numafy several functions
> > > > 
> > > 
> > > <snip>
> > > 
> > > Nish:  glad to see these surface again.  I'll add them [back] into my
> > > tree for testing.  I'm at 24-mm1.  Can't tell from the messages what
> > > release they're against, but I'll sort that out.
> > 
> > They were against -git tip when I rebased ... hrm that would be
> > 551e4fb2465b87de9d4aa1669b27d624435443bb, I believe.
> > 
> > > Another thing:  I've tended to test these atop Mel Gorman's zonelist
> > > rework and a set of mempolicy cleanups that I'm holding pending
> > > acceptance of Mel's patches.  I'll probably do that with these.  At
> > > some point we need to sort out with Andrew when or whether Mel's
> > > patches will hit -mm.  If so, what order vs yours...
> > 
> > I think Mel's patches may be more generally useful than mine (as mine
> > are all keyed on hugepage support). So I would like to see his go first
> > then I can rework mine on top, if that is the order that it ends up
> > happening in.
> 
> Nish:
> 
> Heads up:  Your "smarter retry" patch will need some rework in vmscan.c
> because of the memory controller changes [currently in 24-mm1].  I have
> rebased you patches against 24-mm1, atop Mel's two-zonelist patches and
> my mempolicy cleanup series.  I can send you the entire stack or place
> the tarball on a web site, if you're interested.

I can refresh the patchset for -mm, I was just posting based upon
mainline as that was traditionally how I sent patches to Andrew. But in
this case you're right, there are enough collisions with existing -mm
bits that I should rebase.

Thanks for the heads up.

-Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
