Message-ID: <43EC1A85.2000001@yahoo.com.au>
Date: Fri, 10 Feb 2006 15:45:57 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Implement Swap Prefetching v23
References: <200602101355.41421.kernel@kolivas.org>	<200602101449.59486.kernel@kolivas.org>	<43EC1164.4000605@yahoo.com.au>	<200602101514.40140.kernel@kolivas.org> <20060209202507.26f66be0.akpm@osdl.org>
In-Reply-To: <20060209202507.26f66be0.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Con Kolivas <kernel@kolivas.org>, linux-mm@kvack.org, ck@vds.kolivas.org, pj@sgi.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> Con Kolivas <kernel@kolivas.org> wrote:
> 
>> Ok I see. We don't have a way to add to the tail of that list though?
> 
> 
> del_page_from_lru() + (new) add_page_to_inactive_list_tail().
> 
> 
>>Is that 
>> a worthwhile addition to this (ever growing) project? That would definitely 
>> have an impact on the other code if not all done within swap_prefetch.c.. 
>> which would also be quite a large open coded something.
> 
> 
> Do both of the above in a new function in swap.c.
> 

That'll require the caller to do lru locking.

I'd add an lru_cache_add_tail, use it instead of the current lru_cache_add
that Con's got now, and just implement it in a simple manner, without
pagevecs.

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
