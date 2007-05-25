Date: Fri, 25 May 2007 14:39:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][PATCH 2/3] hugetlb: numafy several functions
Message-Id: <20070525143908.dfcc0060.akpm@linux-foundation.org>
In-Reply-To: <1180126559.5730.73.camel@localhost>
References: <20070516233053.GN20535@us.ibm.com>
	<20070516233155.GO20535@us.ibm.com>
	<20070523175142.GB9301@us.ibm.com>
	<1179947768.5537.37.camel@localhost>
	<20070523192951.GE9301@us.ibm.com>
	<20070525194318.GD31717@us.ibm.com>
	<1180126559.5730.73.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, wli@holomorphy.com, anton@samba.org, clameter@sgi.com, agl@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 25 May 2007 16:55:59 -0400 Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:

> On Fri, 2007-05-25 at 12:43 -0700, Nishanth Aravamudan wrote:
> > Andrew,
> > 
> <snip>
> > > 
> > > Yeah, if folks like the interface and are satisfied with it working,
> > > I'll rebase onto -mm for Andrew's sanity.
> > 
> > Would you like me to rebase onto 2.6.22-rc2-mm1? I think this is a very
> > useful feature for NUMA systems that may have an unequal distribution of
> > memory and don't like the hugepage allocations provided by the global
> > sysctl.
> > 
> > If I recall right, the collisions with Lee's hugetlb.c changes were
> > pretty small, so it shouldn't be any trouble at all.
> 
> Nish:
> 
> Unless I missed your post, I think Andrew is waiting to hear from you on
> the results of your testing of the 22-rc2 based v4 patch before merging
> the huge page allocation fix.
> 

I am in my common state of lost-the-plot on this patchset.

Once all the issues are believed to be settled, please send fresh shiny new
patches against latest -linus or, if there is colliding stuff in -mm,
against latest -mm.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
