Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id D0BC66B005D
	for <linux-mm@kvack.org>; Mon, 14 Sep 2009 15:15:45 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id n8EJFlH9012152
	for <linux-mm@kvack.org>; Mon, 14 Sep 2009 20:15:47 +0100
Received: from pzk10 (pzk10.prod.google.com [10.243.19.138])
	by wpaz24.hot.corp.google.com with ESMTP id n8EJDeqn031369
	for <linux-mm@kvack.org>; Mon, 14 Sep 2009 12:15:45 -0700
Received: by pzk10 with SMTP id 10so20068pzk.17
        for <linux-mm@kvack.org>; Mon, 14 Sep 2009 12:15:44 -0700 (PDT)
Date: Mon, 14 Sep 2009 12:15:43 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 6/6] hugetlb:  update hugetlb documentation for mempolicy
 based management.
In-Reply-To: <20090914154112.GD11778@csn.ul.ie>
Message-ID: <alpine.DEB.1.00.0909141214170.14000@chino.kir.corp.google.com>
References: <20090908200451.GA6481@csn.ul.ie> <alpine.DEB.1.00.0909081307100.13678@chino.kir.corp.google.com> <20090908214109.GB6481@csn.ul.ie> <alpine.DEB.1.00.0909081527320.26432@chino.kir.corp.google.com> <20090909081631.GB24614@csn.ul.ie>
 <alpine.DEB.1.00.0909091335050.7764@chino.kir.corp.google.com> <20090910122641.GA31153@csn.ul.ie> <alpine.DEB.1.00.0909111507540.22083@chino.kir.corp.google.com> <20090914133329.GC11778@csn.ul.ie> <1252937748.17132.111.camel@useless.americas.hpqcorp.net>
 <20090914154112.GD11778@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Nishanth Aravamudan <nacc@us.ibm.com>, linux-numa@vger.kernel.org, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, Eric Whitney <eric.whitney@hp.com>, Randy Dunlap <randy.dunlap@oracle.com>
List-ID: <linux-mm.kvack.org>

On Mon, 14 Sep 2009, Mel Gorman wrote:

> > > > > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > > > > index 83decd6..68abef0 100644
> > > > > --- a/mm/hugetlb.c
> > > > > +++ b/mm/hugetlb.c
> > > > > @@ -1244,6 +1244,7 @@ static int adjust_pool_surplus(struct hstate *h, nodemask_t *nodes_allowed,
> > > > >  	return ret;
> > > > >  }
> > > > >  
> > > > > +#define NUMA_NO_NODE_OBEY_MEMPOLICY (-2)
> > 
> > How about defining NUMA_NO_NODE_OBEY_MEMPOLICY as (NUMA_NO_NODE - 1)
> > just to ensure that it's different.  Not sure it's worth an enum at this
> > point.  NUMA_NO_NODE_OBEY_MEMPOLICY is private to hugetlb at this time.
> > 
> 
> That seems reasonable.
> 

If the nodemask allocation is moved to the sysctl handler and nodemask_t 
is passed into set_max_huge_pages() instead of nid, you don't need 
NUMA_NO_NODE_OBEY_MEMPOLICY at all, though.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
