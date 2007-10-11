Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9B4Tpuv018559
	for <linux-mm@kvack.org>; Thu, 11 Oct 2007 00:29:51 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9B4TohV409570
	for <linux-mm@kvack.org>; Wed, 10 Oct 2007 22:29:50 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9B4Tott022035
	for <linux-mm@kvack.org>; Wed, 10 Oct 2007 22:29:50 -0600
Date: Wed, 10 Oct 2007 21:29:48 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH] hugetlb: fix hugepage allocation with memoryless nodes
Message-ID: <20071011042948.GC32657@us.ibm.com>
References: <20071009012724.GA26472@us.ibm.com> <20071011041119.GB32657@us.ibm.com> <Pine.LNX.4.64.0710102112470.28507@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0710102112470.28507@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: anton@samba.org, akpm@linux-foundation.org, lee.schermerhorn@hp.com, mel@csn.ul.ie, agl@us.ibm.com, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 10.10.2007 [21:14:48 -0700], Christoph Lameter wrote:
> On Wed, 10 Oct 2007, Nishanth Aravamudan wrote:
> 
> > > +++ b/mm/hugetlb.c
> > > @@ -32,6 +32,7 @@ static unsigned int surplus_huge_pages_node[MAX_NUMNODES];
> > >  static gfp_t htlb_alloc_mask = GFP_HIGHUSER;
> > >  unsigned long hugepages_treat_as_movable;
> > >  int hugetlb_dynamic_pool;
> > > +static int last_allocated_nid;
> > 
> > While reworking patch 2/2 to incorporate the current state of hugetlb.c
> > after Adam's stack is applied, I realized that this is not a very good
> > name. It actually is the *current* nid to try to allocate hugepages on.
> > 
> > Christoph, since you proposed the name, do you think
> > 
> > hugetlb_current_nid
> > 
> > is ok, too? If so I'll change the name throughout the patch (no
> > functional change).
> 
> Sure. However, current is bit ambiguous. Is it the node we used last
> or the one to use next? Call it next_hugetlb_nid? Either way is fine
> with me though.

Good point. Given the way the code is laid out now, it always represents
the nid to allocate on next (so is the first one to try).

next_hugetlb_nid or hugetlb_next_nid it is.

Thanks,
Nish


-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
