Date: Wed, 1 Aug 2007 20:01:20 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH/RFC] Allow selected nodes to be excluded from MPOL_INTERLEAVE masks
Message-ID: <20070801110120.GA9449@linux-sh.org>
References: <1185566878.5069.123.camel@localhost> <1185812028.5492.79.camel@localhost> <20070801101651.GA9113@linux-sh.org> <200708011233.02103.ak@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200708011233.02103.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <clameter@sgi.com>, Nishanth Aravamudan <nacc@us.ibm.com>, kxr@sgi.com, akpm@linux-foundation.org, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, Aug 01, 2007 at 12:33:01PM +0200, Andi Kleen wrote:
> On Wednesday 01 August 2007 12:16:51 Paul Mundt wrote:
> > Well, it's not so much the interleave that's the problem so much as
> > _when_ we interleave. The problem with the interleave node mask at system
> > init is that the kernel attempts to spread out data structures across
> > these nodes, which results in us being completely out of memory by the
> > time we get to userspace. After we've booted, supporting MPOL_INTERLEAVE
> > is not so much of a problem, applications just have to be careful with
> > their allocations.
> 
> I assume you got a mostly flat latency machine with a few additional
> small nodes for special purposes, right?
> 
No, each one of the nodes has differing latency, and also differing
characteristics with regards to caching behaviour and things like that.
That's what I was attempting to convey in reply to Andrew:

	http://marc.info/?l=linux-mm&m=118594672828737&w=2

> Would the problem be solved if you just had a per arch CONFIG
> to disable interleaving at boot?  That would be really simple.
> 
As long as interleaving is possible after boot, then yes. It's only the
boot-time interleave that we would like to avoid, and even then, only
across specific nodes (which so far I've just hacked around by removing
small nodes from the interleave map at system init time).

I would also favour an option where we didn't have to set these things as
obscure boot options.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
