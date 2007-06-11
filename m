Date: Mon, 11 Jun 2007 12:43:32 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH v2] gfp.h: GFP_THISNODE can go to other nodes if some
 are unpopulated
In-Reply-To: <20070611193646.GB9920@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0706111240470.19654@schroedinger.engr.sgi.com>
References: <20070607150425.GA15776@us.ibm.com>
 <Pine.LNX.4.64.0706071103240.24988@schroedinger.engr.sgi.com>
 <20070607220149.GC15776@us.ibm.com> <466D44C6.6080105@shadowen.org>
 <Pine.LNX.4.64.0706110911080.15326@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0706110926110.15868@schroedinger.engr.sgi.com>
 <20070611171201.GB3798@us.ibm.com> <Pine.LNX.4.64.0706111122010.18327@schroedinger.engr.sgi.com>
 <20070611193646.GB9920@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Andy Whitcroft <apw@shadowen.org>, Lee.Schermerhorn@hp.com, ak@suse.de, anton@samba.org, mel@csn.ul.ie, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:

> So, I'm splitting up the populated_map patch in two, so that these bits
> or the hugetlbfs bits could be put on top of having that nodemask.

Well maybe just do a single populate_map patch first. We can easily review 
that and get it in. And it will be useful for multiple other patchsets.

> *but*, if this change occurs in mempolicy.c, I think we still have a
> problem, where me->il_next could be initialized in do_set_mempolicy() to
> a memoryless node:

I thought that one misalloc would not be that problematic (hmmmm... unless 
its a hugetlb page on smallist NUMA system...)

> 	if (new && new->policy == MPOL_INTERLEAVE)
> 		current->il_next = first_node(new->v.nodes);

Hmmmm... We could also switch off the nodes in v.nodes? Then we do not 
need any additional checks and the modifications to interleave() are not 
necessary?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
