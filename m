Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 25E4A6B011C
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 20:41:08 -0400 (EDT)
Message-ID: <50512B9A.9060905@ti.com>
Date: Wed, 12 Sep 2012 20:40:58 -0400
From: Cyril Chemparathy <cyril@ti.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: bootmem: use phys_addr_t for physical addresses
References: <1347466008-7231-1-git-send-email-cyril@ti.com> <20120912203920.GU7677@google.com> <505123FE.2090305@ti.com> <20120913003400.GA25889@localhost>
In-Reply-To: <20120913003400.GA25889@localhost>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, davem@davemloft.net, eric.dumazet@gmail.com, hannes@cmpxchg.org, shangw@linux.vnet.ibm.com, vitalya@ti.com

Hi Tejun,

On 9/12/2012 8:34 PM, Tejun Heo wrote:
> Hello,
>
> On Wed, Sep 12, 2012 at 08:08:30PM -0400, Cyril Chemparathy wrote:
>>> So, a function which takes phys_addr_t for goal and limit but returns
>>> void * doesn't make much sense unless the function creates directly
>>> addressable mapping somewhere.
>>
>> On the 32-bit PAE platform in question, physical memory is located
>> outside the 4GB range.  Therefore phys_to_virt takes a 64-bit
>> physical address and returns a 32-bit kernel mapped lowmem pointer.
>
> Yes but phys_to_virt() can return the vaddr only if the physical
> address is already mapped in the kernel address space; otherwise, you
> need one of the kmap*() calls which may not be online early in the
> boot and consumes either the vmalloc area or fixmaps.  bootmem
> interface can't handle unmapped memory.
>

You probably missed the lowmem bit from my response?

This system has all of its memory outside the 4GB physical address 
space.  This includes lowmem, which is permanently mapped into the 
kernel virtual address space as usual.

-- 
Thanks
- Cyril

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
