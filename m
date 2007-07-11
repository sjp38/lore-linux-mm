Date: Wed, 11 Jul 2007 10:48:38 +0100
Subject: Re: -mm merge plans -- anti-fragmentation
Message-ID: <20070711094838.GD7568@skynet.ie>
References: <20070710102043.GA20303@skynet.ie> <20070710130356.GG8779@wotan.suse.de> <Pine.LNX.4.64.0707101142340.11906@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0707101142340.11906@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, kenchen@google.com, jschopp@austin.ibm.com, apw@shadowen.org, kamezawa.hiroyu@jp.fujitsu.com, a.p.zijlstra@chello.nl, y-goto@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On (10/07/07 11:46), Christoph Lameter didst pronounce:
> On Tue, 10 Jul 2007, Nick Piggin wrote:
> 
> > I realise in your pragmatic approach, you are encouraging users to
> > put fallbacks in place in case a higher order page cannot be allocated,
> > but I don't think either higher order pagecache or higher order slubs
> > have such fallbacks (fsblock or a combination of fsblock and higher
> > order pagecache could have, but...).
> 
> We have run mm kernels for month now without the need of a fallback. I 
> purpose of ZONE_MOVABLE was to guarantee that higher order pages could be 
> reclaimed and thus make the scheme reliable?
> 

That and they would be available within a specified limit. With grouping
pages by mobility, high order pages will be available but it's workload
dependant on how many there will be. This sort of predictability is
important for hugepages and memory unplug although it's of less
relevance to order-3 and order-4 users.

> The experience so far shows that the approach works reliably. If there are 
> issues then they need to be fixed. Putting in workarounds in other places 
> such as in fsblock may just be hiding problems if there are any.

I think fsblock as it stands would gain from grouping pages by mobility.
It could use high order pages where they were available and fallback to
using the slower vmap approach when they weren't. I don't see why
highorder page cache and fsblock would be mutually exclusive. For that
matter, I don't see why any of these approachs are mutually exclusive
with what Andrea is doing other than having more than one way of
skinning a cat in the kernal at the same time might be confusing.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
