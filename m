Message-ID: <429E4B22.5080404@yahoo.com.au>
Date: Thu, 02 Jun 2005 09:56:18 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Avoiding external fragmentation with a placement policy Version
 12
References: <20050531112048.D2511E57A@skynet.csn.ul.ie> <429E20B6.2000907@austin.ibm.com> <429E4023.2010308@yahoo.com.au> <20050601234730.GF3998@w-mikek2.ibm.com>
In-Reply-To: <20050601234730.GF3998@w-mikek2.ibm.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mike Kravetz <kravetz@us.ibm.com>
Cc: jschopp@austin.ibm.com, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@osdl.org
List-ID: <linux-mm.kvack.org>

Mike Kravetz wrote:
> On Thu, Jun 02, 2005 at 09:09:23AM +1000, Nick Piggin wrote:
> 
>>It adds a lot of complexity to the page allocator and while
>>it might be very good, the only improvement we've been shown
>>yet is allocating lots of MAX_ORDER allocations I think? (ie.
>>not very useful)
>>
> 
> 
> Allocating lots of MAX_ORDER blocks can be very useful for things
> like hot-pluggable memory.  I know that this may not be of interest
> to most.  However, I've been combining Mel's defragmenting patch
> with the memory hotplug patch set.  As a result, I've been able to
> go from 5GB down to 544MB of memory on my ppc64 system via offline
> operations.  Note that ppc64 only employs a single (DMA) zone.  So,
> page 'grouping' based on use is coming mainly from Mel's patch.
> 

Back in the day, Linus would tell you to take a hike if you
wanted to complicate the buddy allocator to better support
memory hotplug ;)

I don't know what's happened to him now though, he seems to
have gone a little soft on you enterprise types.

Seriously - thanks for the data point, I had an idea that you
guys wanted this for mem hotplug.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
