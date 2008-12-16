Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 630786B0072
	for <linux-mm@kvack.org>; Mon, 15 Dec 2008 20:26:54 -0500 (EST)
Message-ID: <49470433.4050504@goop.org>
Date: Mon, 15 Dec 2008 17:28:19 -0800
From: Jeremy Fitzhardinge <jeremy@goop.org>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] vm_unmap_aliases: allow callers to inhibit TLB flush
References: <49416494.6040009@goop.org> <200707241052.13825.nickpiggin@yahoo.com.au> <4941C568.4070207@goop.org> <200707241140.12945.nickpiggin@yahoo.com.au>
In-Reply-To: <200707241140.12945.nickpiggin@yahoo.com.au>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, the arch/x86 maintainers <x86@kernel.org>, Arjan van de Ven <arjan@linux.intel.com>
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> On Friday 12 December 2008 12:59, Jeremy Fitzhardinge wrote:
>   
>> Nick Piggin wrote:
>>     
>>> Hi,
>>>
>>> On Friday 12 December 2008 06:05, Jeremy Fitzhardinge wrote:
>>>       
>>>> Hi Nick,
>>>>
>>>> In Xen when we're killing the lazy vmalloc aliases, we're only concerned
>>>> about the pagetable references to the mapped pages, not the TLB entries.
>>>>         
>>> Hm? Why is that? Why wouldn't it matter if some page table page gets
>>> written to via a stale TLB?
>>>       
>> No.  Well, yes, it would, but Xen itself will do whatever tlb flushes
>> are necessary to keep it safe (it must, since it doesn't trust guest
>> kernels).  It's fairly clever about working out which cpus need flushing
>> and if other flushes have already done the job.
>>     
>
> OK. Yeah, then the problem is simply that the guest may reuse that virtual
> memory for another vmap.
>   

Hm.  What you would you think of a "deferred tlb flush" flag (or 
something) to cause the next vmap to do the tlb flushes, in the case the 
vunmap happens in a context where the flushes can't be done?

    J
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
