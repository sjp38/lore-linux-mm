Date: Wed, 27 Jun 2007 15:08:13 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 0/11] Shared Policy Overview
In-Reply-To: <200706280001.16383.ak@suse.de>
Message-ID: <Pine.LNX.4.64.0706271506320.32036@schroedinger.engr.sgi.com>
References: <20070625195224.21210.89898.sendpatchset@localhost>
 <1182968078.4948.30.camel@localhost> <Pine.LNX.4.64.0706271427400.31227@schroedinger.engr.sgi.com>
 <200706280001.16383.ak@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, "Paul E. McKenney" <paulmck@us.ibm.com>, linux-mm@kvack.org, akpm@linux-foundation.org, nacc@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Thu, 28 Jun 2007, Andi Kleen wrote:

> > I think one prerequisite to memory policy uses like this is work out how a 
> > memory policy can be handled by the page allocator in such a way that
> > 
> > 1. The use is lightweight and does not impact performance.
> 
> The current mempolicies are all lightweight and zero cost in the main
> allocator path.

Right but with incrementing the policy refcount on each allocation we are 
no longer lightweight.

> The only outlier is still cpusets which does strange stuff, but you
> can't blame mempolicies for that.

What strange stuff does cpusets do? It would be good if further work could 
integration all allocations constraints / special behavior of 
containers/cpusets/memory policies etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
