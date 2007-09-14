Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l8ECu62N009102
	for <linux-mm@kvack.org>; Fri, 14 Sep 2007 08:56:06 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8EE3lTi396688
	for <linux-mm@kvack.org>; Fri, 14 Sep 2007 08:03:47 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8EE3kqo007853
	for <linux-mm@kvack.org>; Fri, 14 Sep 2007 08:03:47 -0600
Subject: Re: [PATCH 4/5] hugetlb: Try to grow hugetlb pool for MAP_SHARED
	mappings
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <200709131724.48818.dave.mccracken@oracle.com>
References: <20070913175855.27074.27030.stgit@kernel>
	 <20070913175940.27074.34082.stgit@kernel>
	 <200709131724.48818.dave.mccracken@oracle.com>
Content-Type: text/plain
Date: Fri, 14 Sep 2007 09:03:46 -0500
Message-Id: <1189778626.15024.48.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave McCracken <dave.mccracken@oracle.com>
Cc: linux-mm@kvack.org, libhugetlbfs-devel@lists.sourceforge.net, Andy Whitcroft <apw@shadowen.org>, Mel Gorman <mel@skynet.ie>, Bill Irwin <bill.irwin@oracle.com>, Ken Chen <kenchen@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-09-13 at 17:24 -0500, Dave McCracken wrote:
> On Thursday 13 September 2007, Adam Litke wrote:
> > +static int gather_surplus_pages(int delta)
> > +{
> > +       struct list_head surplus_list;
> > +       struct page *page, *tmp;
> > +       int ret, i;
> > +       int needed, allocated;
> > +
> > +       needed = (resv_huge_pages + delta) - free_huge_pages;
> > +       if (!needed)
> > +               return 0;
> 
> It looks here like needed can be less than zero.  Do we really intend to 
> continue with the function if that's true?  Or should that test really be "if 
> (needed <= 0)"?

You are right about that.  Thanks for the review :)

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
