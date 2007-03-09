Date: Fri, 9 Mar 2007 13:55:15 +0000 (GMT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [SLUB 0/3] SLUB: The unqueued slab allocator V4
In-Reply-To: <Pine.LNX.4.64.0703081013270.27731@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0703091322140.16052@skynet.skynet.ie>
References: <20070307023502.19658.39217.sendpatchset@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0703081022040.1615@skynet.skynet.ie>
 <Pine.LNX.4.64.0703080836300.27191@schroedinger.engr.sgi.com>
 <20070308174004.GB12958@skynet.ie> <Pine.LNX.4.64.0703081013270.27731@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@osdl.org, Marcelo Tosatti <marcelo@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, mpm@selenic.com, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

On Thu, 8 Mar 2007, Christoph Lameter wrote:

> On Thu, 8 Mar 2007, Mel Gorman wrote:
>
>>> Note that the 16kb page size has a major
>>> impact on SLUB performance. On IA64 slub will use only 1/4th the locking
>>> overhead as on 4kb platforms.
>> It'll be interesting to see the kernbench tests then with debugging
>> disabled.
>
> You can get a similar effect on 4kb platforms by specifying slub_min_order=2 on bootup.
> This means that we have to rely on your patches to allow higher order
> allocs to work reliably though.

It should work out because of the way buddy always selects the minimum 
page size will tend to cluster the slab allocations together whether they 
are reclaimable or not. It's something I can investigate when slub has 
stabilised a bit.

However, in general, high order kernel allocations remain a bad idea. 
Depending on high order allocations that do not group could potentially 
lead to a situation where the movable areas are used more and more by 
kernel allocations. I cannot think of a workload that would actually break 
everything, but it's a possibility.

> The higher the order of slub the less
> locking overhead. So the better your patches deal with fragmentation the
> more we can reduce locking overhead in slub.
>

I can certainly kick it around a lot and see what happen. It's best that 
slub_min_order=2 remain an optional performance enhancing switch though.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
