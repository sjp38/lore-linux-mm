Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id A29596B00D0
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 19:07:48 -0500 (EST)
Message-ID: <4B96E29E.3060305@kernel.org>
Date: Tue, 09 Mar 2010 16:06:54 -0800
From: Yinghai Lu <yinghai@kernel.org>
MIME-Version: 1.0
Subject: Re: further plans on bootmem, was: Re: - bootmem-avoid-dma32-zone-by-default.patch
 removed from -mm tree
References: <201003091940.o29Je4Iq000754@imap1.linux-foundation.org> <4B96B923.7020805@kernel.org> <20100309134902.171ba2ae.akpm@linux-foundation.org> <20100310000121.GA9985@cmpxchg.org>
In-Reply-To: <20100310000121.GA9985@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 03/09/2010 04:01 PM, Johannes Weiner wrote:
> On Tue, Mar 09, 2010 at 01:49:02PM -0800, Andrew Morton wrote:
>> On Tue, 09 Mar 2010 13:09:55 -0800
>> Yinghai Lu <yinghai@kernel.org> wrote:
>>
>>> On 03/09/2010 11:40 AM, akpm@linux-foundation.org wrote:
>>>> The patch titled
>>>>      bootmem: avoid DMA32 zone by default
>>>> has been removed from the -mm tree.  Its filename was
>>>>      bootmem-avoid-dma32-zone-by-default.patch
>>>>
>>>> This patch was dropped because I'm all confused
>>>>
>>>
>>> Thanks for that...
>>
>> Well.  I did drop it because I'm all confused.  It may come back.
>>
>> If Johannes is working in the direction of removing and simplifying
>> code then that's a high priority.  So I'm waiting to see where this
>> discussion leads (on the mailing list, please!)
> 
> I am not working on simplifying in this area at the moment.  I am just
> questioning the discrepancy between the motivation of Yinghai's patch
> series to skip bootmem on x86 and its actual outcome.
> 
> The stated reason for the series was that the amount of memory allocators
> involved in bootstrapping mm on x86 'seemed a bit excessive'. [1]
> 
> I am perfectly fine with the theory: select one mechanism and see whether
> it can be bridged and consequently _removed_.  To shrink the code base,
> shrink text size, make the boot process less complex, more robust etc.
> 
> What I take away from this patchset, however, is that all it really does
> is make the early_res stuff from x86 generic code and add a semantically
> different version of the bootmem API on top of it, selectable with a config
> option.  The diffstat balance is an increase of around 900 lines of code.
> 
> Note that it still uses bootmem to actually bootstrap the page allocator,
> that we now have two implementations of the bootmem interface and no real
> plan - as far as I am informed - to actually change this.
> 
> I also found it weird that it makes x86 skip an allocator level that all
> the other architectures are using, and replaces it with 'generic' code that
> nobody but x86 is using (sparc, powerpc, sh and microblaze  appear to have
> lib/lmb.c at this stage and for this purpose? lmb was also suggested by
> benh [4] but I have to admit I do not understand Yinghai's response to it).
> 

next steps:
1. create kernel/fw_memmap.c, and move common code from arch/x86/kernel/e820.c to it
2. merge lmb with fw_memmap.c/early_res.c
   so some arch that use lmb will fw_memmap/earl_res.c 

YH

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
