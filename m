Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5EG76jI007103
	for <linux-mm@kvack.org>; Thu, 14 Jun 2007 12:07:06 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5EG76AA558328
	for <linux-mm@kvack.org>; Thu, 14 Jun 2007 12:07:06 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5EG76tV027272
	for <linux-mm@kvack.org>; Thu, 14 Jun 2007 12:07:06 -0400
Date: Thu, 14 Jun 2007 09:07:04 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC 10/13] Memoryless nodes: Fix GFP_THISNODE behavior
Message-ID: <20070614160704.GE7469@us.ibm.com>
References: <20070614075026.607300756@sgi.com> <20070614075336.405903951@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070614075336.405903951@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 14.06.2007 [00:50:36 -0700], clameter@sgi.com wrote:
> GFP_THISNODE checks that the zone selected is within the pgdat (node) of the
> first zone of a nodelist. That only works if the node has memory. A
> memoryless node will have its first node on another pgdat (node).
> 
> GFP_THISNODE currently will return simply memory on the first pgdat.
> Thus it is returning memory on other nodes. GFP_THISNODE should fail
> if there is no local memory on a node.
> 
> 
> Add a new set of zonelists for each node that only contain the nodes
> that belong to the zones itself so that no fallback is possible.

Should be

Add a new set of zonelists for each node that only contain the zones
that belong to the node itself so that no fallback is possible?

This is the last patch in the stack I should based my patches on,
correct (I believe 11-13 were mis-sends)?

Will test everything and send out Acks later today, hopefully.

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
