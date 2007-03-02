Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l22H6YVP017384
	for <linux-mm@kvack.org>; Fri, 2 Mar 2007 12:06:34 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l22H5I4V270634
	for <linux-mm@kvack.org>; Fri, 2 Mar 2007 12:05:18 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l22H5Iic031136
	for <linux-mm@kvack.org>; Fri, 2 Mar 2007 12:05:18 -0500
Message-ID: <45E8594B.6020904@austin.ibm.com>
Date: Fri, 02 Mar 2007 11:05:15 -0600
From: Joel Schopp <jschopp@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: The performance and behaviour of the anti-fragmentation related
 patches
References: <20070301101249.GA29351@skynet.ie> <20070301160915.6da876c5.akpm@linux-foundation.org> <Pine.LNX.4.64.0703011642190.12485@woody.linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0703011642190.12485@woody.linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@skynet.ie>, npiggin@suse.de, clameter@engr.sgi.com, mingo@elte.hu, arjan@infradead.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> On Thu, 1 Mar 2007, Andrew Morton wrote:
>> So some urgent questions are: how are we going to do mem hotunplug and
>> per-container RSS?

The people who were trying to do memory hot-unplug basically all stopped waiting for 
these patches, or something similar, to solve the fragmentation problem.  Our last 
working set of patches built on top of an earlier version of Mel's list based solution.

> 
> Also: how are we going to do this in virtualized environments? Usually the 
> people who care abotu memory hotunplug are exactly the same people who 
> also care (or claim to care, or _will_ care) about virtualization.

Yes, we are.  And we are very much in favor of these patches.  At last year's OLS 
developers from IBM, HP, Xen coauthored a paper titled "Resizing Memory with Balloons 
and Hotplug".  http://www.linuxsymposium.org/2006/linuxsymposium_procv2.pdf  Our 
conclusion was that ballooning is simply not good enough and we need memory 
hot-unplug.  Here is a quote from the article I find relevant to today's discussion:

"Memory Hotplug remove is not in mainline.
Patches exist, released under the GPL, but are
only occasionally rebased. To be worthwhile
the existing patches would need either a remappable
kernel, which remains highly doubtful, or
a fragmentation avoidance strategy to keep migrateable
and non-migrateable pages clumped
together nicely."

At IBM all of our Power4, Power5, and future hardware supports a lot of 
virtualization features.  This hardware took "Best Virtualization Solution" at 
LinuxWorld Expo, so we aren't talking research projects here. 
http://www-03.ibm.com/press/us/en/pressrelease/20138.wss

> My personal opinion is that while I'm not a huge fan of virtualization, 
> these kinds of things really _can_ be handled more cleanly at that layer, 
> and not in the kernel at all. Afaik, it's what IBM already does, and has 
> been doing for a while. There's no shame in looking at what already works, 
> especially if it's simpler.

I believe you are talking about the zSeries (aka mainframe) because the rest of IBM 
needs these patches.  zSeries built their whole processor instruction set, memory 
model, etc around their form of virtualization, and I doubt the rest of us are going 
to change our processor instruction set that drastically.  I've had a lot of talks 
with Martin Schwidefsky (the maintainer of Linux on zSeries) about how we could do 
more of what they do and the basic answer is we can't because what they do is so 
fundamentally incompatible.

While I appreciate that we should all dump our current hardware and buy mainframes it 
seems to me that an easier solution is to take a few patches from Mel and work with 
the hardware we already have.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
