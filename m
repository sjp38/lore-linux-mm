Message-ID: <46A6D5E1.70407@yahoo.com.au>
Date: Wed, 25 Jul 2007 14:47:29 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: NUMA policy issues with ZONE_MOVABLE
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, ak@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@skynet.ie>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> The outcome of the 2.6.23 merge was surprising. No antifrag but only 
> ZONE_MOVABLE. ZONE_MOVABLE is the highest zone.

ZONE_MOVABLE is the way to be able to guarantee contiguous memory
for hotplug and hugetlb without wasting too much memory, and is
very unintrusive for what it does. I think it was a good step
forward.

There is still disagreement about the antifrag patches, so what
is surprising about this outcome?


> For the NUMA layer this has some weird consequences if ZONE_MOVABLE is populated
> 
> 1. It is the highest zone.
> 
> 2. Thus policy_zone == ZONE_MOVABLE
> 
> ZONE_MOVABLE contains only movable allocs by default. That is anonymous 
> pages and page cache pages?
> 
> The NUMA layer only supports NUMA policies for the highest zone. 
> Thus NUMA policies can control anonymous pages and the page cache pages 
> allocated from ZONE_MOVABLE. 
> 
> However, NUMA policies will no longer affect non pagecache and non 
> anonymous allocations. So policies can no longer redirect slab allocations 
> and huge page allocations (unless huge page allocations are moved to 
> ZONE_MOVABLE). And there are likely other allocations that are not 
> movable.
> 
> If ZONE_MOVABLE is off then things should be working as normal.
> 
> Doesnt this mean that ZONE_MOVABLE is incompatible with CONFIG_NUMA?

I guess it has similar problems as ZONE_HIGHMEM etc. I think the
zoned allocator and NUMA was there first, so it might be more
correct to say that mempolicies are incompatible with them :)

But I thought you had plans to fix mempolicies to do zones better?
What happened to that?

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
