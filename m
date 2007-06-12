Date: Tue, 12 Jun 2007 11:51:17 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] populated_map: fix !NUMA case, remove comment
In-Reply-To: <1181674081.5592.91.camel@localhost>
Message-ID: <Pine.LNX.4.64.0706121150220.30754@schroedinger.engr.sgi.com>
References: <20070611234155.GG14458@us.ibm.com>
 <Pine.LNX.4.64.0706111642450.24042@schroedinger.engr.sgi.com>
 <20070612000705.GH14458@us.ibm.com>  <Pine.LNX.4.64.0706111740280.24389@schroedinger.engr.sgi.com>
  <20070612020257.GF3798@us.ibm.com>  <Pine.LNX.4.64.0706111919450.25134@schroedinger.engr.sgi.com>
  <20070612023209.GJ3798@us.ibm.com>  <Pine.LNX.4.64.0706111953220.25390@schroedinger.engr.sgi.com>
  <20070612032055.GQ3798@us.ibm.com> <1181660782.5592.50.camel@localhost>
 <20070612172858.GV3798@us.ibm.com> <1181674081.5592.91.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Jun 2007, Lee Schermerhorn wrote:

> Well, my patch [v4] fixed it on my platform.  So this is a regression
> relative to my patch.  But, then, my patch had an issue with an x86_64
> system where one node is all/mostly DMA32 and other nodes have memory in
> higher zones.  Maybe that's OK [or not] for hugepage allocation, but
> almost certainly not for regular page interleaving, ...

Well this means your patch was arch specific.

> > I'm much more concerned in the short term about the whole
> > memoryless-node issue, which I think is more straight-forward, and
> > generic to fix.
> 
> Perhaps, but I think we're still going to get off node allocations with
> the revised definition of the populated map and the new zonelist
> ordering.  I think we'll need to check for and reject off-node
> allocations when '_THISNODE is specified.  We can't assume that the
> first zone in a node's zonelist for a given gfp_zone is on-node.

We do not do that anymore. GFP_THISNODE guarantees the allocation on 
the node with alloc_pages_node. Read on.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
