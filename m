Date: Wed, 30 Jul 2008 18:23:18 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC] [PATCH 0/5 V2] Huge page backed user-space stacks
Message-ID: <20080730172317.GA14138@csn.ul.ie>
References: <cover.1216928613.git.ebmunson@us.ibm.com> <20080730014308.2a447e71.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080730014308.2a447e71.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric Munson <ebmunson@us.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, libhugetlbfs-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On (30/07/08 01:43), Andrew Morton didst pronounce:
> On Mon, 28 Jul 2008 12:17:10 -0700 Eric Munson <ebmunson@us.ibm.com> wrote:
> 
> > Certain workloads benefit if their data or text segments are backed by
> > huge pages.
> 
> oh.  As this is a performance patch, it would be much better if its
> description contained some performance measurement results!  Please.
> 

I ran these patches through STREAM (http://www.cs.virginia.edu/stream/).
STREAM itself was patched to allocate data from the stack instead of statically
for the test. They completed without any problem on x86, x86_64 and PPC64
and each test showed a performance gain from using hugepages.  I can post
the raw figures but they are not currently in an eye-friendly format. Here
are some plots of the data though;

x86: http://www.csn.ul.ie/~mel/postings/stack-backing-20080730/x86-stream-stack.ps
x86_64: http://www.csn.ul.ie/~mel/postings/stack-backing-20080730/x86_64-stream-stack.ps
ppc64-small: http://www.csn.ul.ie/~mel/postings/stack-backing-20080730/ppc64-small-stream-stack.ps
ppc64-large: http://www.csn.ul.ie/~mel/postings/stack-backing-20080730/ppc64-large-stream-stack.ps

The test was to run STREAM with different array sizes (plotted on X-axis)
and measure the average throughput (y-axis). In each case, backing the stack
with large pages with a performance gain.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
