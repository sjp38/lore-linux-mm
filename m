Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5BKIWHX029733
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 16:18:32 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5BKINKC058178
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 14:18:23 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5BKIMLR014602
	for <linux-mm@kvack.org>; Mon, 11 Jun 2007 14:18:22 -0600
Date: Mon, 11 Jun 2007 13:18:14 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH v2] gfp.h: GFP_THISNODE can go to other nodes if some are unpopulated
Message-ID: <20070611201814.GC9920@us.ibm.com>
References: <20070607150425.GA15776@us.ibm.com> <Pine.LNX.4.64.0706071103240.24988@schroedinger.engr.sgi.com> <20070607220149.GC15776@us.ibm.com> <466D44C6.6080105@shadowen.org> <Pine.LNX.4.64.0706110911080.15326@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0706110926110.15868@schroedinger.engr.sgi.com> <20070611171201.GB3798@us.ibm.com> <Pine.LNX.4.64.0706111122010.18327@schroedinger.engr.sgi.com> <20070611193646.GB9920@us.ibm.com> <Pine.LNX.4.64.0706111240470.19654@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706111240470.19654@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andy Whitcroft <apw@shadowen.org>, Lee.Schermerhorn@hp.com, ak@suse.de, anton@samba.org, mel@csn.ul.ie, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 11.06.2007 [12:43:32 -0700], Christoph Lameter wrote:
> On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:
> 
> > So, I'm splitting up the populated_map patch in two, so that these bits
> > or the hugetlbfs bits could be put on top of having that nodemask.
> 
> Well maybe just do a single populate_map patch first. We can easily review 
> that and get it in. And it will be useful for multiple other patchsets.

Right, sorry, that's what I meant -- I was moving ahead to the other
patches to make sure everything was sensible.

Will send out the populated_map patch ASAP.

> > *but*, if this change occurs in mempolicy.c, I think we still have a
> > problem, where me->il_next could be initialized in do_set_mempolicy() to
> > a memoryless node:
> 
> I thought that one misalloc would not be that problematic (hmmmm... unless 
> its a hugetlb page on smallist NUMA system...)

Right -- it all depends...

> > 	if (new && new->policy == MPOL_INTERLEAVE)
> > 		current->il_next = first_node(new->v.nodes);
> 
> Hmmmm... We could also switch off the nodes in v.nodes? Then we do not
> need any additional checks and the modifications to interleave() are
> not necessary?

Ah true, so that would happen at mpol_new() time. Makes sense.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
