Subject: Re: [PATCH] Document Linux Memory Policy - V2
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0707311206330.6053@schroedinger.engr.sgi.com>
References: <20070725111646.GA9098@skynet.ie>
	 <Pine.LNX.4.64.0707251212300.8820@schroedinger.engr.sgi.com>
	 <20070726132336.GA18825@skynet.ie>
	 <Pine.LNX.4.64.0707261104360.2374@schroedinger.engr.sgi.com>
	 <20070726225920.GA10225@skynet.ie>
	 <Pine.LNX.4.64.0707261819530.18210@schroedinger.engr.sgi.com>
	 <20070727082046.GA6301@skynet.ie> <20070727154519.GA21614@skynet.ie>
	 <Pine.LNX.4.64.0707271026040.15990@schroedinger.engr.sgi.com>
	 <1185559260.5069.40.camel@localhost>  <20070731151434.GA18506@skynet.ie>
	 <1185899686.6240.64.camel@localhost>
	 <Pine.LNX.4.64.0707311206330.6053@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 31 Jul 2007 15:46:55 -0400
Message-Id: <1185911215.6240.100.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Mel Gorman <mel@skynet.ie>, linux-mm@kvack.org, ak@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, akpm@linux-foundation.org, pj@sgi.com, Michael Kerrisk <mtk-manpages@gmx.net>, Randy Dunlap <randy.dunlap@oracle.com>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Tue, 2007-07-31 at 12:10 -0700, Christoph Lameter wrote:
> On Tue, 31 Jul 2007, Lee Schermerhorn wrote:
> 
> > > Is it worth mentioning numactl here?
> > 
> > Actually, I tried not to mention numactl by name--just that that APIs
> > and headers reside in an "out of tree" package.  This is a kernel doc
> > and I wasn't sure about referencing out of tree "stuff"..  Andi
> > suggested that I not try to describe the syscalls in any detail [thus my
> > updates to the man pages], and I removed that.  But, I'll figure out a
> > way to forward reference the brief API descriptions later in the doc.
> 
> numactl definitely must be mentioned because it is the user space API for 
> these things.

OK.  I'll mention it, but won't go into any detail as this is a kernel
tree doc.

> 
> > > This appears to contradict the previous paragram. The last paragraph
> > > would imply that the policy is applied to mappings that are mmaped
> > > MAP_SHARED where they really only apply to shmem mappings.
> > 
> > Conceptually, shared policies apply to shared "memory objects".
> > However, the implementation is incomplete--only shmem/shm object
> > currently support this concept.  [I'd REALLY like to fix this, but am
> > getting major push back... :-(]  
> 
> The shmem implementation has bad semantics (affects other processes 
> that are unaware of another process redirecting its memory accesses) and 
> should not be extended to other types of object.

<heavy sigh>  I won't rise to the bait, Christoph...

> 
> > > It's sufficent to say that MPOL_BIND will restrict the process to allocating
> > > pages within a set of nodes specified by a nodemask because the end result
> > > from the external observer will be similar.
> > 
> > OK.  But, I don't want to lose the idea that, with the BIND policy,
> > pages will be allocated first from one of the nodes [lowest #] and then
> > from the next and so on.  This is important, because I've had colleagues
> > complain to me that it was broken.  They thought that if they bound a
> > multithread application to cpus on several nodes and to the same nodes
> > memories, they would get local allocation with fall back only to the
> > nodes they specified.  They really wanted cpuset semantics, but these
> > were not available at the time.
> 
> Right. That is something that would be fixed if we could pass a nodemask 
> to alloc_pages.

OK.  We can update the doc when/if that happens.

> > OK.  I'll rework this entire section.  Again, I don't want to lose what
> > I think are important semantics for a user.  And, maybe by documenting
> > ugly behavior for all to see, we'll do something about it?
> 
> Correct. I hope you include the ugly shared shmem semantics with the 
> effect on unsuspecting processes?

Again, I refuse to bite...



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
