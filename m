Date: Mon, 5 Mar 2007 04:21:16 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: The performance and behaviour of the anti-fragmentation related patches
Message-ID: <20070305032116.GA29678@wotan.suse.de>
References: <20070301101249.GA29351@skynet.ie> <20070301160915.6da876c5.akpm@linux-foundation.org> <Pine.LNX.4.64.0703011642190.12485@woody.linux-foundation.org> <45E8594B.6020904@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <45E8594B.6020904@austin.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Joel Schopp <jschopp@austin.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@skynet.ie>, clameter@engr.sgi.com, mingo@elte.hu, arjan@infradead.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 02, 2007 at 11:05:15AM -0600, Joel Schopp wrote:
> Linus Torvalds wrote:
> >
> >On Thu, 1 Mar 2007, Andrew Morton wrote:
> >>So some urgent questions are: how are we going to do mem hotunplug and
> >>per-container RSS?
> 
> The people who were trying to do memory hot-unplug basically all stopped 
> waiting for these patches, or something similar, to solve the fragmentation 
> problem.  Our last working set of patches built on top of an earlier 
> version of Mel's list based solution.
> 
> >
> >Also: how are we going to do this in virtualized environments? Usually the 
> >people who care abotu memory hotunplug are exactly the same people who 
> >also care (or claim to care, or _will_ care) about virtualization.
> 
> Yes, we are.  And we are very much in favor of these patches.  At last 
> year's OLS developers from IBM, HP, Xen coauthored a paper titled "Resizing 
> Memory with Balloons and Hotplug".  
> http://www.linuxsymposium.org/2006/linuxsymposium_procv2.pdf  Our 
> conclusion was that ballooning is simply not good enough and we need memory 
> hot-unplug.  Here is a quote from the article I find relevant to today's 
> discussion:

But if you don't require a lot of higher order allocations anyway, then
guest fragmentation caused by ballooning doesn't seem like much problem.

If you need higher order allocations, then ballooning is bad because of
fragmentation, so you need memory unplug, so you need higher order
allocations. Goto 1.

Balooning probably does skew memory management stats and watermarks, but
that's just because it is implemented as a module. A couple of hooks
should be enough to allow things to be adjusted?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
