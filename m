Subject: Re: [PATCH 01/14] NUMA: Generic management of nodemasks for
	various purposes
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0708011037510.20795@schroedinger.engr.sgi.com>
References: <20070727194316.18614.36380.sendpatchset@localhost>
	 <20070727194322.18614.68855.sendpatchset@localhost>
	 <20070731192241.380e93a0.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0707311946530.6158@schroedinger.engr.sgi.com>
	 <20070731200522.c19b3b95.akpm@linux-foundation.org>
	 <Pine.LNX.4.64.0707312006550.22443@schroedinger.engr.sgi.com>
	 <20070731203203.2691ca59.akpm@linux-foundation.org>
	 <1185977011.5059.36.camel@localhost>
	 <Pine.LNX.4.64.0708011037510.20795@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Wed, 01 Aug 2007 13:54:43 -0400
Message-Id: <1185990883.5059.54.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, ak@suse.de, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Mel Gorman <mel@skynet.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2007-08-01 at 10:41 -0700, Christoph Lameter wrote:
> On Wed, 1 Aug 2007, Lee Schermerhorn wrote:
> 
> > I think Andrew is referring to the "exclude selected nodes from
> > interleave policy" and "preferred policy fixups" patches.  Those are
> > related to the memoryless node patches in the sense that they touch some
> > of the same lines in mempolicy.c.  However, IMO, those patches shouldn't
> > gate the memoryless node series once the i386 issues are resolved.
> 
> Right. I think we first need to get the basic set straight. In order to be 
> complete we need to audit all uses of node_online() in the kernel and 
> think about those uses. They may require either N_NORMAL_MEMORY or 
> N_HIGH_MEMORY depending on the check being for a page cache or a kernel 
> allocation.
> 
> Then we need to test on esoteric NUMA systems like NUMAQ and embedded.

And HP's ia64 platform.

> 
> On the way we may add some additional stuff like interleave policy 
> settings, restricting node use for hugh pages and slab etc. 
> All of these are likely going to be important for asymmetric NUMA 
> configurations that the memoryless_nodes patchset is going to address.
> 

Agree.  The memoryless nodes set makes it fairly easy to add these
restrictions, I think, by using the new node_states[] support.  I just
want to keep the discussion going, as our asymmetric platform needs this
support for policies to work as desired.

Later,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
