Message-ID: <43EC1164.4000605@yahoo.com.au>
Date: Fri, 10 Feb 2006 15:07:00 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Implement Swap Prefetching v23
References: <200602101355.41421.kernel@kolivas.org> <20060209192556.2629e36b.akpm@osdl.org> <200602101449.59486.kernel@kolivas.org>
In-Reply-To: <200602101449.59486.kernel@kolivas.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, ck@vds.kolivas.org, pj@sgi.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Con Kolivas wrote:
> On Friday 10 February 2006 14:25, Andrew Morton wrote:
> 
>>Con Kolivas <kernel@kolivas.org> wrote:
>>
>>>Here's a respin with Nick's suggestions and a modification to not cost us
>>>extra slab on non-numa.
>>
>>v23?  I'm sure we can do better than that.
> 
> 
> :D
> 
> 
>>>This patch implements swap prefetching when the vm is relatively idle and
>>>there is free ram available.
>>
>>I think "free ram available" is the critical thing here.  If it doesn't
>>evict anyhing else then OK, it basically uses unutilised disk bandwidth for
>>free.
>>
>>But where does it put the pages?  If it was really "free", they'd go onto
>>the tail of the inactive list.
> 
> 
> It puts them in swapcache. This seems to work nicely as a nowhere-land place 
> where they don't have much affect on anything until we need them or need more 
> ram. This has worked well, but I'm open to other suggestions.
> 

Well they go on the head of the inactive list and will kick out file
backed pagecache. Which was my concern about reducing the usefulness
of useful swapping on desktop systems.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
