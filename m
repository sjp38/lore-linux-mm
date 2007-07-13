Message-ID: <469751E9.7060904@shadowen.org>
Date: Fri, 13 Jul 2007 11:20:25 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: -mm merge plans -- anti-fragmentation
References: <20070710102043.GA20303@skynet.ie> <20070712122925.192a6601.akpm@linux-foundation.org>
In-Reply-To: <20070712122925.192a6601.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@skynet.ie>, npiggin@suse.de, kenchen@google.com, jschopp@austin.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, a.p.zijlstra@chello.nl, y-goto@jp.fujitsu.com, clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Tue, 10 Jul 2007 11:20:43 +0100
> mel@skynet.ie (Mel Gorman) wrote:
> 
>>> create-the-zone_movable-zone.patch
>>> allow-huge-page-allocations-to-use-gfp_high_movable.patch
>>> handle-kernelcore=-generic.patch
>>>
>>>  Mel's moveable-zone work.  In a similar situation.  We need to stop whatever
>>>  we're doing and get down and work out what we're going to do with all this
>>>  stuff.
>>>
>> Whatever about grouping pages by mobility, I would like to see these go
>> through. They have a real application for hugetlb pool resizing where the
>> administrator knows the range of hugepages that will be required but doesn't
>> want to waste memory when the required number of hugepages is small. I've
>> cc'd Kenneth Chen as I believe he has run into this problem recently where
>> I believe partitioning memory would have helped. He'll either confirm or deny.
> 
> Still no decision here, really.
> 
> Should we at least go for
> 
> add-__gfp_movable-for-callers-to-flag-allocations-from-high-memory-that-may-be-migrated.patch
> create-the-zone_movable-zone.patch
> allow-huge-page-allocations-to-use-gfp_high_movable.patch
> handle-kernelcore=-generic.patch
> 
> in 2.6.23?

These patches are pretty simple and self-contained utilising the
existing zone infrastructure.  They provide a significant degree of
placement control when configured, which gives a lot of the benefits of
grouping-pages-by-mobility.  Merging these would seem like a low-risk
option.

Having a degree of placement control as delivered by ZONE_MOVABLE
greatly increases the effectiveness of lumpy reclaim at higher orders.
These patches plus lumpy would (IMO) provide a good base for further
development.  In particular I would envisage better usability for
hugepage users in terms of simpler configuration.

I would like to see ZONE_MOVABLE and lumpy considered for 2.6.23.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
