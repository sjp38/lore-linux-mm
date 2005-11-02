Message-ID: <43687C3D.7060706@yahoo.com.au>
Date: Wed, 02 Nov 2005 19:43:41 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
References: <1130917338.14475.133.camel@localhost> <436877DB.7020808@yahoo.com.au> <20051102172729.9E7C.Y-GOTO@jp.fujitsu.com>
In-Reply-To: <20051102172729.9E7C.Y-GOTO@jp.fujitsu.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, "Martin J. Bligh" <mbligh@mbligh.org>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

Yasunori Goto wrote:
>>>One other thing, if we decide to take the zones approach, it would have
>>>no other side benefits for the kernel.  It would be for hotplug only and
>>>I don't think even the large page users would get much benefit.  
>>>
>>
>>Hugepage users? They can be satisfied with ZONE_REMOVABLE too. If you're
>>talking about other higher-order users, I still think we can't guarantee
>>past about order 1 or 2 with Mel's patch and they simply need to have
>>some other ways to do things.
> 
> 
> Hmmm. I don't see at this point.
> Why do you think ZONE_REMOVABLE can satisfy for hugepage.
> At leaset, my ZONE_REMOVABLE patch doesn't any concern about
> fragmentation.
> 

Well I think it can satisfy hugepage allocations simply because
we can be reasonably sure of being able to free contiguous regions.
Of course it will be memory no longer easily reclaimable, same as
the case for the frag patches. Nor would be name ZONE_REMOVABLE any
longer be the most appropriate!

But my point is, the basic mechanism is there and is workable.
Hugepages and memory unplug are the two main reasons for IBM to be
pushing this AFAIKS.

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
