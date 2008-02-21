Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id m1L5AZPI000377
	for <linux-mm@kvack.org>; Thu, 21 Feb 2008 10:40:35 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1L5AZ1j1134654
	for <linux-mm@kvack.org>; Thu, 21 Feb 2008 10:40:35 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id m1L5AZHl020752
	for <linux-mm@kvack.org>; Thu, 21 Feb 2008 05:10:35 GMT
Message-ID: <47BD06C2.5030602@linux.vnet.ibm.com>
Date: Thu, 21 Feb 2008 10:36:10 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] Document huge memory/cache overhead of memory controller
 in Kconfig
References: <20080220122338.GA4352@basil.nowhere.org> <47BC2275.4060900@linux.vnet.ibm.com> <200802211535.38932.nickpiggin@yahoo.com.au>
In-Reply-To: <200802211535.38932.nickpiggin@yahoo.com.au>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@osdl.org, torvalds@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> On Wednesday 20 February 2008 23:52, Balbir Singh wrote:
>> Andi Kleen wrote:
>>> Document huge memory/cache overhead of memory controller in Kconfig
>>>
>>> I was a little surprised that 2.6.25-rc* increased struct page for the
>>> memory controller.  At least on many x86-64 machines it will not fit into
>>> a single cache line now anymore and also costs considerable amounts of
>>> RAM.
>> The size of struct page earlier was 56 bytes on x86_64 and with 64 bytes it
>> won't fit into the cacheline anymore? Please also look at
>> http://lwn.net/Articles/234974/
> 
> BTW. We'll probably want to increase the width of some counters
> in struct page at some point for 64-bit, so then it really will
> go over with the memory controller!
> 

Hmm...

> Actually, an external data structure is a pretty good idea. We
> could probably do it easily with a radix tree (pfn->memory
> controller). And that might be a better option for distros.
> 

I'll put in my long list of TODOs. I started looking at it yesterday again and
here are my early thoughts

1. We could create something similar to mem_map, we would need to handle 4
different ways of creating mem_map.
2. On x86 with 64 GB ram, if we decided to use vmalloc space, we would need 64
MB of vmalloc'ed memory

I have not explored your latest suggestion of pfn <-> memory controller mapping
yet. I'll explore it and see how that goes.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
