Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id m1M4k5VH005703
	for <linux-mm@kvack.org>; Fri, 22 Feb 2008 10:16:05 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1M4k5G6995476
	for <linux-mm@kvack.org>; Fri, 22 Feb 2008 10:16:05 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id m1M4k4ox024636
	for <linux-mm@kvack.org>; Fri, 22 Feb 2008 04:46:05 GMT
Message-ID: <47BE527D.2070109@linux.vnet.ibm.com>
Date: Fri, 22 Feb 2008 10:11:33 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] Document huge memory/cache overhead of memory controller
 in Kconfig
References: <20080220122338.GA4352@basil.nowhere.org> <47BC2275.4060900@linux.vnet.ibm.com> <200802211535.38932.nickpiggin@yahoo.com.au> <47BD06C2.5030602@linux.vnet.ibm.com> <47BD55F6.5030203@firstfloor.org>
In-Reply-To: <47BD55F6.5030203@firstfloor.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, akpm@osdl.org, torvalds@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
>> 1. We could create something similar to mem_map, we would need to handle 4
> 
> 4? At least x86 mainline only has two ways now. flatmem and vmemmap.
> 
>> different ways of creating mem_map.
> 
> Well it would be only a single way to create the "aux memory controller
> map" (or however it will be called). Basically just a call to single
> function from a few different places.
> 
>> 2. On x86 with 64 GB ram, 
> 
> First i386 with 64GB just doesn't work, at least not with default 3:1
> split. Just calculate it yourself how much of the lowmem area is left
> after the 64GB mem_map is allocated. Typical rule of thumb is that 16GB
> is the realistic limit for 32bit x86 kernels. Worrying about
> anything more does not make much sense.
> 

I understand what you say Andi, but nothing in the kernel stops us from
supporting 64GB. Should a framework like memory controller make an assumption
that not more than 16GB will be configured on an x86 box?

>> if we decided to use vmalloc space, we would need 64
>> MB of vmalloc'ed memory
> 
> Yes and if you increase mem_map you need exactly the same space
> in lowmem too. So increasing the vmalloc reservation for this is
> equivalent. Just make sure you use highmem backed vmalloc.
> 

I see two problems with using vmalloc. One, the reservation needs to be done
across architectures. Two, a big vmalloc chunk is not node aware, if all the
pages come from the same node, we have a penalty to pay in a NUMA system.

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
