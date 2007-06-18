Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5IGlm35019455
	for <linux-mm@kvack.org>; Mon, 18 Jun 2007 12:47:48 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5IGlmLZ040796
	for <linux-mm@kvack.org>; Mon, 18 Jun 2007 10:47:48 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5IGlmqt024851
	for <linux-mm@kvack.org>; Mon, 18 Jun 2007 10:47:48 -0600
Date: Mon, 18 Jun 2007 09:47:22 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC 10/13] Memoryless nodes: Fix GFP_THISNODE behavior
Message-ID: <20070618164722.GA10714@us.ibm.com>
References: <20070614075026.607300756@sgi.com> <20070614075336.405903951@sgi.com> <20070614160704.GE7469@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070614160704.GE7469@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 14.06.2007 [09:07:04 -0700], Nishanth Aravamudan wrote:
> On 14.06.2007 [00:50:36 -0700], clameter@sgi.com wrote:
> > GFP_THISNODE checks that the zone selected is within the pgdat (node) of the
> > first zone of a nodelist. That only works if the node has memory. A
> > memoryless node will have its first node on another pgdat (node).
> > 
> > GFP_THISNODE currently will return simply memory on the first pgdat.
> > Thus it is returning memory on other nodes. GFP_THISNODE should fail
> > if there is no local memory on a node.
> > 
> > 
> > Add a new set of zonelists for each node that only contain the nodes
> > that belong to the zones itself so that no fallback is possible.
> 
> Should be
> 
> Add a new set of zonelists for each node that only contain the zones
> that belong to the node itself so that no fallback is possible?
> 
> This is the last patch in the stack I should based my patches on,
> correct (I believe 11-13 were mis-sends)?
> 
> Will test everything and send out Acks later today, hopefully.

Tested on a 4-node ppc64 w/ 2 memoryless nodes and a 4-node x86_64 w/
no memoryless nodes, with my patches applied on top (will send out the
latest versions again).

All get

Acked-by: Nishanth Aravamudan <nacc@us.ibm.com>

Thanks for doing this work, Christoph!

-Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
