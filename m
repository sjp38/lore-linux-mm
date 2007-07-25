Message-ID: <46A6DE75.70803@yahoo.com.au>
Date: Wed, 25 Jul 2007 15:24:05 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: NUMA policy issues with ZONE_MOVABLE
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com> <46A6D5E1.70407@yahoo.com.au> <Pine.LNX.4.64.0707242200380.4070@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0707242200380.4070@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, ak@suse.de, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@skynet.ie>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Wed, 25 Jul 2007, Nick Piggin wrote:
> 
> 
>>>Doesnt this mean that ZONE_MOVABLE is incompatible with CONFIG_NUMA?
>>
>>I guess it has similar problems as ZONE_HIGHMEM etc. I think the
>>zoned allocator and NUMA was there first, so it might be more
>>correct to say that mempolicies are incompatible with them :)
> 
> 
> Highmem is only used on i386 NUMA and works fine on NUMAQ. The current 
> zone types are carefully fitted to existing NUMA systems.

I don't understand what you mean. Aren't mempolicies also supposed to
work on NUMAQ too? How about DMA and DMA32 allocations?


>>But I thought you had plans to fix mempolicies to do zones better?
> 
> 
> No sure where you got that from. I repeatedly suggested that more zones be 
> removed because of this one and other issues.

Oh I must have been mistaken.

Well I guess you haven't succeeded in getting zones removed, so I think
we should make mempolicies work better with zones.

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
