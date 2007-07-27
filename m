Subject: Re: [PATCH] Document Linux Memory Policy - V2
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070727113836.9471e35e.randy.dunlap@oracle.com>
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com>
	 <20070725111646.GA9098@skynet.ie>
	 <Pine.LNX.4.64.0707251212300.8820@schroedinger.engr.sgi.com>
	 <20070726132336.GA18825@skynet.ie>
	 <Pine.LNX.4.64.0707261104360.2374@schroedinger.engr.sgi.com>
	 <20070726225920.GA10225@skynet.ie>
	 <Pine.LNX.4.64.0707261819530.18210@schroedinger.engr.sgi.com>
	 <20070727082046.GA6301@skynet.ie> <20070727154519.GA21614@skynet.ie>
	 <Pine.LNX.4.64.0707271026040.15990@schroedinger.engr.sgi.com>
	 <1185559260.5069.40.camel@localhost>
	 <20070727113836.9471e35e.randy.dunlap@oracle.com>
Content-Type: text/plain
Date: Fri, 27 Jul 2007 15:01:28 -0400
Message-Id: <1185562889.5069.68.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, ak@suse.de, Mel Gorman <mel@skynet.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, akpm@linux-foundation.org, pj@sgi.com, Michael Kerrisk <mtk-manpages@gmx.net>, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-07-27 at 11:38 -0700, Randy Dunlap wrote:
> On Fri, 27 Jul 2007 14:00:59 -0400 Lee Schermerhorn wrote:
> 
> > [PATCH] Document Linux Memory Policy - V2
> > 
> >  Documentation/vm/memory_policy.txt |  278 +++++++++++++++++++++++++++++++++++++
> >  1 file changed, 278 insertions(+)
> > 
> > Index: Linux/Documentation/vm/memory_policy.txt
> > ===================================================================
> > --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> > +++ Linux/Documentation/vm/memory_policy.txt	2007-07-27 13:40:45.000000000 -0400
> > @@ -0,0 +1,278 @@
> > +
> 
> ...
> 
> > +
> > +MEMORY POLICY CONCEPTS
> > +
> > +Scope of Memory Policies
> > +
> > +The Linux kernel supports four more or less distinct scopes of memory policy:
> > +
> > +    System Default Policy:  this policy is "hard coded" into the kernel.  It
> > +    is the policy that governs the all page allocations that aren't controlled
> 
>                               drop ^ "the"
> 
> > +    by one of the more specific policy scopes discussed below.
> 
> Are these policies listed in order of "less specific scope to more
> specific scope"?

Randy:

Thanks for the quick review.   I will make the edits you suggest and
re-post after the weekend [hoping for more feedback...].

To answer your question, yes, it was my intent to order them from least
specific [or most general?] to most specific.  Shall I say so?

Other than these items, does the document make sense?  Do you think it's
worth adding?  Andi was concerned about having documentation in too many
places [code + doc].

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
