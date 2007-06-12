Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5CLhvDI025598
	for <linux-mm@kvack.org>; Tue, 12 Jun 2007 17:43:57 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5CLgqjC557558
	for <linux-mm@kvack.org>; Tue, 12 Jun 2007 17:42:52 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5CLgp0C015500
	for <linux-mm@kvack.org>; Tue, 12 Jun 2007 17:42:51 -0400
Date: Tue, 12 Jun 2007 14:42:49 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 1/3] NUMA: introduce node_memory_map
Message-ID: <20070612214249.GI3798@us.ibm.com>
References: <20070612204843.491072749@sgi.com> <20070612205738.309078596@sgi.com> <alpine.DEB.0.99.0706121401060.5104@chino.kir.corp.google.com> <Pine.LNX.4.64.0706121407070.1850@schroedinger.engr.sgi.com> <alpine.DEB.0.99.0706121409170.5104@chino.kir.corp.google.com> <20070612213612.GH3798@us.ibm.com> <Pine.LNX.4.64.0706121437480.5196@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706121437480.5196@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: David Rientjes <rientjes@google.com>, akpm@linux-foundation.org, linux-mm@kvack.org, ak@suse.de, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On 12.06.2007 [14:39:21 -0700], Christoph Lameter wrote:
> 
> > Indeed, I did and (I like to think) I helped write the patches :)
> 
> The patches contain your signoff because of your authorship...
> 
> > We can keep
> > 
> > node_set_memory()
> > node_clear_memory()
> > 
> > but change node_memory() to node_has_memory() ?
> 
> Hmmm.... That deviates from how the other node_xxx() things are so it
> disturbed my sense of order. We have no three word node_is/has_xxx
> yet.

Yeah, I realize that -- but I also agree with David that

	node_memory()

is not intuitive at all. And we've already admitted that a few of the
macros in there are inconsistent already :)

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
