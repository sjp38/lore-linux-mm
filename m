Date: Wed, 9 May 2007 17:55:06 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch] check cpuset mems_allowed for sys_mbind
In-Reply-To: <b040c32a0705091747x75f45eacwbe11fe106be71833@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0705091749180.2374@schroedinger.engr.sgi.com>
References: <b040c32a0705091611mb35258ap334426e42d33372c@mail.gmail.com>
 <20070509164859.15dd347b.pj@sgi.com> <b040c32a0705091747x75f45eacwbe11fe106be71833@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ken Chen <kenchen@google.com>
Cc: Paul Jackson <pj@sgi.com>, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 9 May 2007, Ken Chen wrote:

> > Looking back through the version history of mm/mempolicy.c, I see that
> > we used to check the cpuset (by calling contextualize_policy), but then
> > with the following patch (Christoph added to CC list above), this was
> > changed.
> 
> oh, boy, never ending circle of fixing a bug by introduce another one.
> No wonder why number of kernel bugs never goes down because everyone
> is running in circles.
> 
> I see Christoph's point that when two threads live in two disjoint
> cpusets, they can affect each other's memory policy and cause
> undesired oom behavior.

s/undesired/unexpected/

> However, mbind shouldn't create discrepancy between what is allowed
> and what is promised, especially with MPOL_BIND policy.  Since a
> numa-aware app has already gone such a detail to request memory
> placement on a specific nodemask, they fully expect memory to be
> placed there for performance reason.  If kernel lies about it, we get
> very unpleasant performance issue.

How does the kernel lie? The memory is placed given the current cpuset and 
memory policy restrictions.
 
> I suppose neither behavior is correct nor desired.  What if we "OR"
> all the nodemask for all threads in a process group and use that
> nodemask to check against what is being requested, is that reasonable?

Pretty serious hackery there.

I think there is a rather large portioin of people rather frustated with 
the inconsistencies in the memory policy layer. If you can come up with 
some broader scheme to fix this then we would all be happier.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
