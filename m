Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l5CLVkLD028810
	for <linux-mm@kvack.org>; Tue, 12 Jun 2007 17:31:46 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5CLaE4b255430
	for <linux-mm@kvack.org>; Tue, 12 Jun 2007 15:36:15 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5CLaEVv023833
	for <linux-mm@kvack.org>; Tue, 12 Jun 2007 15:36:14 -0600
Date: Tue, 12 Jun 2007 14:36:12 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 1/3] NUMA: introduce node_memory_map
Message-ID: <20070612213612.GH3798@us.ibm.com>
References: <20070612204843.491072749@sgi.com> <20070612205738.309078596@sgi.com> <alpine.DEB.0.99.0706121401060.5104@chino.kir.corp.google.com> <Pine.LNX.4.64.0706121407070.1850@schroedinger.engr.sgi.com> <alpine.DEB.0.99.0706121409170.5104@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.0.99.0706121409170.5104@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@linux-foundation.org, linux-mm@kvack.org, ak@suse.de, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On 12.06.2007 [14:10:44 -0700], David Rientjes wrote:
> On Tue, 12 Jun 2007, Christoph Lameter wrote:
> 
> > On Tue, 12 Jun 2007, David Rientjes wrote:
> > 
> > > >   * int node_online(node)		Is some node online?
> > > >   * int node_possible(node)		Is some node possible?
> > > > + * int node_memory(node)		Does a node have memory?
> > > >   *
> > > 
> > > This name doesn't make sense; wouldn't node_has_memory() be better?
> > 
> > node_set_has_memory and node_clear_has_memory sounds a bit strange.
> > 
> 
> This will probably be one of those things that people see in the
> source and have to look up everytime.  node_has_memory() is
> straight-forward and to the point.

Indeed, I did and (I like to think) I helped write the patches :)

Why not just make the boolean sensible?

We can keep

node_set_memory()
node_clear_memory()

but change node_memory() to node_has_memory() ?

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
