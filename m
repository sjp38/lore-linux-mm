Message-ID: <43EC13EB.3010501@yahoo.com.au>
Date: Fri, 10 Feb 2006 15:17:47 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Implement Swap Prefetching v23
References: <200602101355.41421.kernel@kolivas.org> <200602101449.59486.kernel@kolivas.org> <43EC1164.4000605@yahoo.com.au> <200602101514.40140.kernel@kolivas.org>
In-Reply-To: <200602101514.40140.kernel@kolivas.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, ck@vds.kolivas.org, pj@sgi.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Con Kolivas wrote:
> On Friday 10 February 2006 15:07, Nick Piggin wrote:

>>Well they go on the head of the inactive list and will kick out file
>>backed pagecache. Which was my concern about reducing the usefulness
>>of useful swapping on desktop systems.
> 
> 
> Ok I see. We don't have a way to add to the tail of that list though? Is that 
> a worthwhile addition to this (ever growing) project? That would definitely 

Don't know, can you tell us?

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
