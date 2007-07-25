Message-ID: <46A6E922.5030902@yahoo.com.au>
Date: Wed, 25 Jul 2007 16:09:38 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: NUMA policy issues with ZONE_MOVABLE
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com> <46A6D5E1.70407@yahoo.com.au> <Pine.LNX.4.64.0707242200380.4070@schroedinger.engr.sgi.com> <46A6DE75.70803@yahoo.com.au> <Pine.LNX.4.64.0707242256100.4425@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0707242256100.4425@schroedinger.engr.sgi.com>
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
>>>Highmem is only used on i386 NUMA and works fine on NUMAQ. The current zone
>>>types are carefully fitted to existing NUMA systems.
>>
>>I don't understand what you mean. Aren't mempolicies also supposed to
>>work on NUMAQ too? How about DMA and DMA32 allocations?
> 
> 
> Memory policies work on NUMAQ. Please read up on memory policies.

Because the first 1GB will be on one node? Ok, maybe that happens
to work in an ugly sort of way. How about DMA32 then?

Do you disagree that mempolices should be made to work better with
multiple zones?

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
