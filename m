Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5C1flKe002291
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 21:41:47 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5C1fjHi465124
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 21:41:47 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5C1fiNU020368
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 21:41:45 -0400
Date: Mon, 11 Jun 2007 18:41:42 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH v2][RFC] Fix INTERLEAVE with memoryless nodes
Message-ID: <20070612014142.GC3798@us.ibm.com>
References: <20070611202728.GD9920@us.ibm.com> <Pine.LNX.4.64.0706111417540.20454@schroedinger.engr.sgi.com> <20070611221036.GA14458@us.ibm.com> <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com> <20070611225213.GB14458@us.ibm.com> <20070611230829.GC14458@us.ibm.com> <Pine.LNX.4.64.0706111613100.23857@schroedinger.engr.sgi.com> <20070612001436.GI14458@us.ibm.com> <20070611175700.e5268342.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070611175700.e5268342.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, lee.schermerhorn@hp.com, anton@samba.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 11.06.2007 [17:57:00 -0700], Andrew Morton wrote:
> On Mon, 11 Jun 2007 17:14:36 -0700 Nishanth Aravamudan <nacc@us.ibm.com> wrote:
> 
> > 
> > Christoph said:
> > "This does not work for the address based interleaving for anonymous
> > vmas.  I am not sure what to do there. We could change the calculation
> > of the node to be based only on nodes with memory and then skip the
> > memoryless ones. I have only added a comment to describe its brokennes
> > for now."
> > 
> > I have copied his draft's comment.
> > 
> > Change alloc_pages_node() to fail __GFP_THISNODE allocations if the node
> > is not populated.
> > 
> > Again, Christoph said:
> > "This will fix the alloc_pages_node case but not the alloc_pages() case.
> > In the alloc_pages() case we do not specify a node. Implicitly it is
> > understood that we (in the case of no memory policy / cpuset options)
> > allocate from the nearest node. So it may be argued there that the
> > GFP_THISNODE behavior of taking the first node from the zonelist is
> > okay."
> > 
> > Christoph was also worried about the performance impact on these paths,
> > as am I.
> > 
> > Finally, as he suggested, uninline alloc_pages_node() and move it to
> > mempolicy.c.
> > 
> 
> All confused.

<snip>

> I have no node_populated_mask.
> 
> The below improves the situation, but I wonder about, ahem, the maturity of
> this code.

Sorry, Andrew :(

I didn't expect you to pull all these patche so quickly. No one gave me
much feedback the last few times I posted the series, so I wasn't
expecting any this time either...that's what I get for pique-ing
Christoph's interest :) We went through several revisions today alone...

If you would prefer dropping the series, I will clean them up and get
them ready for you tomorrow.

The previous series were well-tested, but this one was more of a RFD/RFC
with an emphasis on the D/C. Sorry for that and not making it more
explicit.

How would you like me to proceed?

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
