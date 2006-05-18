Message-ID: <446C2191.70300@yahoo.com.au>
Date: Thu, 18 May 2006 17:26:09 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: limit lowmem_reserve
References: <200604021401.13331.kernel@kolivas.org> <200605180011.43216.kernel@kolivas.org> <446C1E25.4080408@yahoo.com.au> <200605181721.38735.kernel@kolivas.org>
In-Reply-To: <200605181721.38735.kernel@kolivas.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: Andrew Morton <akpm@osdl.org>, ck@vds.kolivas.org, linux list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Con Kolivas wrote:
> On Thursday 18 May 2006 17:11, Nick Piggin wrote:
> 
>>If we're under memory pressure, kswapd will try to free up any candidate
>>zone, yes.
>>
>>
>>>On my test case this indeed happens and my ZONE_DMA never goes below 3000
>>>pages free. If I lower the reserve even further my pages free gets stuck
>>>at 3208 and can't free any more, and doesn't ever drop below that either.
>>>
>>>Here is the patch I was proposing
>>
>>What problem does that fix though?
> 
> 
> It's a generic concern and I honestly don't know how significant it is which 
> is why I'm asking if it needs attention. That concern being that any time 
> we're under any sort of memory pressure, ZONE_DMA will undergo intense 
> reclaim even though there may not really be anything specifically going on in 
> ZONE_DMA. It just seems a waste of cycles doing that.
> 

If it doesn't have any/much pagecache or slab cache in it, there won't be
intense reclaim; if it does then it can be reclaimed and the memory used.

reclaim / allocation could be slightly smarter about scaling watermarks,
however I don't think it is much of an issue at the moment.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
