Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5RNkbfn010565
	for <linux-mm@kvack.org>; Wed, 27 Jun 2007 19:46:37 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5RNkZ9X557280
	for <linux-mm@kvack.org>; Wed, 27 Jun 2007 19:46:37 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5RNkZIx026092
	for <linux-mm@kvack.org>; Wed, 27 Jun 2007 19:46:35 -0400
Date: Wed, 27 Jun 2007 16:46:34 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH/RFC 0/11] Shared Policy Overview
Message-ID: <20070627234634.GI8604@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20070625195224.21210.89898.sendpatchset@localhost> <1182968078.4948.30.camel@localhost> <Pine.LNX.4.64.0706271427400.31227@schroedinger.engr.sgi.com> <200706280001.16383.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200706280001.16383.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, akpm@linux-foundation.org, nacc@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Thu, Jun 28, 2007 at 12:01:16AM +0200, Andi Kleen wrote:
> 
> > The zonelist from MPOL_BIND is passed to __alloc_pages. As a result the 
> > RCU lock must be held over the call into the page allocator with reclaim 
> > etc etc. Note that the zonelist is part of the policy structure.
> 
> Yes I realized this at some point too. RCU doesn't work here because
> __alloc_pages can sleep. Have to use the reference counts even though
> it adds atomic operations.

Any reason SRCU wouldn't work here?  From a quick glance at the patch,
it seems possible to me.

							Thanx, Paul

> > I think one prerequisite to memory policy uses like this is work out how a 
> > memory policy can be handled by the page allocator in such a way that
> > 
> > 1. The use is lightweight and does not impact performance.
> 
> The current mempolicies are all lightweight and zero cost in the main
> allocator path.
> 
> The only outlier is still cpusets which does strange stuff, but you
> can't blame mempolicies for that.
> 
> -Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
