Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp04.au.ibm.com (8.13.1/8.13.1) with ESMTP id m1MFpZ5J031526
	for <linux-mm@kvack.org>; Sat, 23 Feb 2008 02:51:35 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1MFtZ4j223446
	for <linux-mm@kvack.org>; Sat, 23 Feb 2008 02:55:35 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1MFpuf1029753
	for <linux-mm@kvack.org>; Sat, 23 Feb 2008 02:51:57 +1100
Message-ID: <47BEEE84.3070003@linux.vnet.ibm.com>
Date: Fri, 22 Feb 2008 21:17:16 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] Document huge memory/cache overhead of memory controller
 in Kconfig
References: <20080220122338.GA4352@basil.nowhere.org> <47BC2275.4060900@linux.vnet.ibm.com> <200802211535.38932.nickpiggin@yahoo.com.au> <47BD06C2.5030602@linux.vnet.ibm.com> <47BD55F6.5030203@firstfloor.org> <47BE527D.2070109@linux.vnet.ibm.com> <47BE9B11.7090809@firstfloor.org> <47BEBCB7.8000607@linux.vnet.ibm.com> <20080222130002.GA22369@one.firstfloor.org>
In-Reply-To: <20080222130002.GA22369@one.firstfloor.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, akpm@osdl.org, torvalds@osdl.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
> On Fri, Feb 22, 2008 at 05:44:47PM +0530, Balbir Singh wrote:
>> My concern with all the points you mentioned is that this solution might need to
>> change again,
> 
> No why would it need to change again?
> 
>> depending on the factors you've mentioned. vmalloc() is good and
>> straightforward, but it has these dependencies which could call for another
>> rewrite of the code.
> 
> The hotplug change would not need a rewrite of anything, just
> some additional code in the SRAT parser to increase __VMALLOC_RESERVE for
> each hotplug region. It's likely <= 3 additional lines.
> 

Yes, but that is hotplug changes only for i386/x86-64.

>>>>>> if we decided to use vmalloc space, we would need 64
>>>>>> MB of vmalloc'ed memory
>>>>> Yes and if you increase mem_map you need exactly the same space
>>>>> in lowmem too. So increasing the vmalloc reservation for this is
>>>>> equivalent. Just make sure you use highmem backed vmalloc.
>>>>>
>>>> I see two problems with using vmalloc. One, the reservation needs to be done
>>>> across architectures. 
>>> Only on 32bit. Ok hacking it into all 32bit architectures might be
>>> difficult, but I assume it would be ok to rely on the architecture
>>> maintainers for that and only enable it on some selected architectures
>>> using Kconfig for now.
>>>
>> Yes, but that's not such a good idea
> 
> Waiting for the maintainers? Why not? 

It limits the platforms the code can run on. A feature independent of the
architecture should if possible not depend on architecture specific support

> 
> I assume the memory controller would be primarily used on larger
> systems anyways and except for i386 these should be mostly 64bit
> these days anyways.
> 
>>> On 64bit vmalloc should be by default large enough so it could
>>> be enabled for all 64bit architectures.
>>>
>>>> Two, a big vmalloc chunk is not node aware, 
>>> vmalloc_node()
>>>
>> vmalloc_node() would need to work much the same way as mem_map does. I am
> 
> would? It already is implemented and works just fine AFAIK. 
> 
> I don't understand the rest of your point.
> 

Oh! I guess, it's the extra I am. The point I was trying to make was that we
would need to split up the cgroup map the same way as the per node mem_map.

> -Andi


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
