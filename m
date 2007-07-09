Message-ID: <46920A0C.3040400@yahoo.com.au>
Date: Mon, 09 Jul 2007 20:12:28 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [RFC/PATCH] Use mmu_gather for fork() instead of flush_tlb_mm()
References: <1183952874.3388.349.camel@localhost.localdomain>	 <1183962981.5961.3.camel@localhost.localdomain>	 <1183963544.5961.6.camel@localhost.localdomain>	 <4691E64F.5070506@yahoo.com.au>	 <1183972349.5961.25.camel@localhost.localdomain>	 <4691FFDC.5020808@yahoo.com.au> <1183974458.5961.42.camel@localhost.localdomain>
In-Reply-To: <1183974458.5961.42.camel@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linux-mm@kvack.org, Linux Kernel list <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Benjamin Herrenschmidt wrote:
> On Mon, 2007-07-09 at 19:29 +1000, Nick Piggin wrote:
> 
>>They could just #define one to the other though, there are only a
>>small
>>number of them. Is there a downside to not making them distinct? i386
>>for example probably would just keep doing a tlb flush for fork and
>>not
>>want to worry about touching the tlb gather stuff.
> 
> 
> But the tlb gather stuff just does ... a flush_tlb_mm() on x86 :-)

But it still does the get_cpu of the mmu gather data structure and
has to look in there and touch the cacheline. You're also having to
do more work when unlocking/relocking the ptl etc.


> I really think it's the right API



-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
