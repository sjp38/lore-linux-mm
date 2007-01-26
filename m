Date: Fri, 26 Jan 2007 17:37:27 +0000 (GMT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/8] Allow huge page allocations to use GFP_HIGH_MOVABLE
In-Reply-To: <Pine.LNX.4.64.0701260921310.7301@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0701261727400.23091@skynet.skynet.ie>
References: <20070125234458.28809.5412.sendpatchset@skynet.skynet.ie>
 <20070125234558.28809.21103.sendpatchset@skynet.skynet.ie>
 <Pine.LNX.4.64.0701260832260.6141@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0701261649040.23091@skynet.skynet.ie>
 <Pine.LNX.4.64.0701260903110.6966@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0701261720120.23091@skynet.skynet.ie>
 <Pine.LNX.4.64.0701260921310.7301@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 26 Jan 2007, Christoph Lameter wrote:

> On Fri, 26 Jan 2007, Mel Gorman wrote:
>
>>> What is the e1000 problem? Jumbo packet allocation via GFP_KERNEL?
>> Yes. Potentially the anti-fragmentation patches could address this by
>> clustering atomic allocations together as much as possible.
>
> GFP_ATOMIC allocs?

Yes

> Do you have a reference to the thread where this was
> discussed?
>

It's come up a few times and the converation is always fairly similar 
although the thread http://lkml.org/lkml/2006/9/22/44 has interesting 
information on the topic. There has been no serious discussion on whether 
anti-fragmentation would help it or not. I think it would if atomic 
allocations were clustered together because then jumbo frame allocations 
would cluster together in the same MAX_ORDER blocks and tend to keep other 
allocations away.


-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
