From: Paul Cameron Davies <pauld@cse.unsw.EDU.AU>
Date: Thu, 25 Jan 2007 11:17:22 +1100 (EST)
Subject: Re: [PATCH 1/1] Page Table cleanup patch
In-Reply-To: <45B6CE8C.8010807@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0701251116040.4081@weill.orchestra.cse.unsw.EDU.AU>
References: <20070124023828.11302.51100.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
 <45B6CE8C.8010807@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Nick

On Wed, 24 Jan 2007, Nick Piggin wrote:

> Paul Davies wrote:
>> This patch is a proposed cleanup of the current page table organisation.
>> Such a cleanup would be a logical first step towards introducing at least
>> a partial clean page table interface, geared towards providing enhanced 
>> virtualization oportunities for x86.  It is also a common sense cleanup in 
>> its own right.
>>
>>  * Creates mlpt.c to hold the page table implementation currently held 
>> in memory.c.
>>  * Adjust Makefile  * Move implementation dependent page table code out of 
>> include/linux/mm.h into include/linux/mlpt-mm.h
>>  * Move implementation dependent page table code out of 
>> include/asm-generic/pgtable.h to include/asm-generic/pgtable-mlpt.h
>> 
>> mlpt stands from multi level page table.
>
> Hi Paul,
>
> I'm not sure that I see the point of this patch alone, as there is still
> all the mlpt implementation details in all the page table walkers. Or
> did you have a scheme to change implementations somehow just using the
> p*d_addr_next?

This patch alone doesn't acheive nearly enough.  Separating out as much
implementation (without tackling the walkers) would be a start though.
The MLPT appears to be intrinsic to the kernel owing to its open coding, 
and starting to isolate its implementation (even partially) is an 
important step towards destroying this misconception.

I strongly prefer not to go down the path of using a scheme to change 
implementations with p*d_addr_next.  I tried this kind of thing early on 
and it was horribly ugly.  There are far cleaner ways to do it.

Cheers

Paul Davies

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
