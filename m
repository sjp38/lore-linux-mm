Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0916E6B0055
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 07:48:39 -0400 (EDT)
Date: Tue, 15 Sep 2009 12:48:45 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 6/6] hugetlb:  update hugetlb documentation for
	mempolicy based management.
Message-ID: <20090915114844.GA31840@csn.ul.ie>
References: <20090908214109.GB6481@csn.ul.ie> <alpine.DEB.1.00.0909081527320.26432@chino.kir.corp.google.com> <20090909081631.GB24614@csn.ul.ie> <alpine.DEB.1.00.0909091335050.7764@chino.kir.corp.google.com> <20090910122641.GA31153@csn.ul.ie> <alpine.DEB.1.00.0909111507540.22083@chino.kir.corp.google.com> <20090914133329.GC11778@csn.ul.ie> <1252937748.17132.111.camel@useless.americas.hpqcorp.net> <20090914154112.GD11778@csn.ul.ie> <alpine.DEB.1.00.0909141214170.14000@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.00.0909141214170.14000@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Nishanth Aravamudan <nacc@us.ibm.com>, linux-numa@vger.kernel.org, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, Eric Whitney <eric.whitney@hp.com>, Randy Dunlap <randy.dunlap@oracle.com>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 14, 2009 at 12:15:43PM -0700, David Rientjes wrote:
> On Mon, 14 Sep 2009, Mel Gorman wrote:
> 
> > > > > > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > > > > > index 83decd6..68abef0 100644
> > > > > > --- a/mm/hugetlb.c
> > > > > > +++ b/mm/hugetlb.c
> > > > > > @@ -1244,6 +1244,7 @@ static int adjust_pool_surplus(struct hstate *h, nodemask_t *nodes_allowed,
> > > > > >  	return ret;
> > > > > >  }
> > > > > >  
> > > > > > +#define NUMA_NO_NODE_OBEY_MEMPOLICY (-2)
> > > 
> > > How about defining NUMA_NO_NODE_OBEY_MEMPOLICY as (NUMA_NO_NODE - 1)
> > > just to ensure that it's different.  Not sure it's worth an enum at this
> > > point.  NUMA_NO_NODE_OBEY_MEMPOLICY is private to hugetlb at this time.
> > > 
> > 
> > That seems reasonable.
> > 
> 
> If the nodemask allocation is moved to the sysctl handler and nodemask_t 
> is passed into set_max_huge_pages() instead of nid, you don't need 
> NUMA_NO_NODE_OBEY_MEMPOLICY at all, though.
> 

Very likely. When V7 comes out, I'll spin a patch for that and see what
it looks like if Lee doesn't beat me to it.


-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
