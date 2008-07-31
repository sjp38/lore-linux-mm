From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [RFC] [PATCH 0/5 V2] Huge page backed user-space stacks
Date: Thu, 31 Jul 2008 16:04:14 +1000
References: <cover.1216928613.git.ebmunson@us.ibm.com> <20080730172317.GA14138@csn.ul.ie> <20080730103407.b110afc2.akpm@linux-foundation.org>
In-Reply-To: <20080730103407.b110afc2.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200807311604.14349.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Eric Munson <ebmunson@us.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, libhugetlbfs-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Thursday 31 July 2008 03:34, Andrew Morton wrote:
> On Wed, 30 Jul 2008 18:23:18 +0100 Mel Gorman <mel@csn.ul.ie> wrote:
> > On (30/07/08 01:43), Andrew Morton didst pronounce:
> > > On Mon, 28 Jul 2008 12:17:10 -0700 Eric Munson <ebmunson@us.ibm.com> 
wrote:
> > > > Certain workloads benefit if their data or text segments are backed
> > > > by huge pages.
> > >
> > > oh.  As this is a performance patch, it would be much better if its
> > > description contained some performance measurement results!  Please.
> >
> > I ran these patches through STREAM (http://www.cs.virginia.edu/stream/).
> > STREAM itself was patched to allocate data from the stack instead of
> > statically for the test. They completed without any problem on x86,
> > x86_64 and PPC64 and each test showed a performance gain from using
> > hugepages.  I can post the raw figures but they are not currently in an
> > eye-friendly format. Here are some plots of the data though;
> >
> > x86:
> > http://www.csn.ul.ie/~mel/postings/stack-backing-20080730/x86-stream-stac
> >k.ps x86_64:
> > http://www.csn.ul.ie/~mel/postings/stack-backing-20080730/x86_64-stream-s
> >tack.ps ppc64-small:
> > http://www.csn.ul.ie/~mel/postings/stack-backing-20080730/ppc64-small-str
> >eam-stack.ps ppc64-large:
> > http://www.csn.ul.ie/~mel/postings/stack-backing-20080730/ppc64-large-str
> >eam-stack.ps
> >
> > The test was to run STREAM with different array sizes (plotted on X-axis)
> > and measure the average throughput (y-axis). In each case, backing the
> > stack with large pages with a performance gain.
>
> So about a 10% speedup on x86 for most STREAM configurations.  Handy -
> that's somewhat larger than most hugepage-conversions, iirc.

Although it might be a bit unusual to have codes doing huge streaming
memory operations on stack memory...

We can see why IBM is so keen on their hugepages though :)


> Do we expect that this change will be replicated in other
> memory-intensive apps?  (I do).

Such as what? It would be nice to see some numbers with some HPC or java
or DBMS workload using this. Not that I dispute it will help some cases,
but 10% (or 20% for ppc) I guess is getting toward the best case, short
of a specifically written TLB thrasher.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
