From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Document Linux Memory Policy
Date: Tue, 29 May 2007 22:16:30 +0200
References: <1180467234.5067.52.camel@localhost> <Pine.LNX.4.64.0705291247001.26308@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0705291247001.26308@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200705292216.31102.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, mtk-manpages@gmx.net
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tuesday 29 May 2007 22:04, Christoph Lameter wrote:

> > +	Currently [2.6.22], only shared memory segments, created by shmget(),
> > +	support shared policy.  When shared policy support was added to Linux,
> > +	the associated data structures were added to shared hugetlbfs segments.
> > +	However, at the time, hugetlbfs did not support allocation at fault
> > +	time--a.k.a lazy allocation--so hugetlbfs segments were never "hooked
> > +	up" to the shared policy support.  Although hugetlbfs segments now
> > +	support lazy allocation, their support for shared policy has not been
> > +	completed.
>
> I guess patches would be welcome to complete it.

I actually had it working in SLES9 (which sported a lazy hugetlb 
implementation somewhat different from what mainline has now) 
Somehow it dropped off the radar in mainline, but it should be easy
to readd.

> But that may only be 
> releveant if huge pages are shared between processes. 

NUMA policy is useful for multithreaded processes too

> We so far have no 
> case in which that support is required.

Besides I think hugetlbfs mappings can be shared anyways.


> > +	    If the Preferred policy specifies more than one node, the node
> > +	    with the numerically lowest node id will be selected to start
> > +	    the allocation scan.
>
> AFAIK perferred policy was only intended to specify one node.

Yes.

Also the big difference to MPOL_BIND is that it is not strict and will fall 
back like the default policy.

> > +	    For allocation of page cache pages, Interleave mode indexes the set
> > +	    of nodes specified by the policy using a node counter maintained
> > +	    per task.  This counter wraps around to the lowest specified node
> > +	    after it reaches the highest specified node.  This will tend to
> > +	    spread the pages out over the nodes specified by the policy based
> > +	    on the order in which they are allocated, rather than based on any
> > +	    page offset into an address range or file.
>
> Which is particularly important if random pages in a file are used.

Not sure that should be documented too closely -- it is a implementation
detail that could change.

>
> > +	'flags' may also contain 'MPOL_F_NODE'.  This flag has been
> > +	described in some get_mempolicy() man pages as "not for application
> > +	use" and subject to change.  Applications are cautioned against
> > +	using it.  However, for completeness and because it is useful for
> > +	testing the kernel memory policy support, current behavior is
> > +	documented here:
>
> The docs are wrong. This is fully supported.

Yes, I gave up on that one and the warning in the manpage should be 
probably dropped 

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
