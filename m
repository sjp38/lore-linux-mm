Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id D33FF6B0110
	for <linux-mm@kvack.org>; Wed, 12 Sep 2012 20:08:37 -0400 (EDT)
Message-ID: <505123FE.2090305@ti.com>
Date: Wed, 12 Sep 2012 20:08:30 -0400
From: Cyril Chemparathy <cyril@ti.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: bootmem: use phys_addr_t for physical addresses
References: <1347466008-7231-1-git-send-email-cyril@ti.com> <20120912203920.GU7677@google.com>
In-Reply-To: <20120912203920.GU7677@google.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, davem@davemloft.net, eric.dumazet@gmail.com, hannes@cmpxchg.org, shangw@linux.vnet.ibm.com, vitalya@ti.com

Hi Tejun,

On 9/12/2012 4:39 PM, Tejun Heo wrote:
> Hello,
>
> On Wed, Sep 12, 2012 at 12:06:48PM -0400, Cyril Chemparathy wrote:
>>   static void * __init alloc_bootmem_core(unsigned long size,
>>   					unsigned long align,
>> -					unsigned long goal,
>> -					unsigned long limit)
>> +					phys_addr_t goal,
>> +					phys_addr_t limit)
>
> So, a function which takes phys_addr_t for goal and limit but returns
> void * doesn't make much sense unless the function creates directly
> addressable mapping somewhere.
>

On the 32-bit PAE platform in question, physical memory is located 
outside the 4GB range.  Therefore phys_to_virt takes a 64-bit physical 
address and returns a 32-bit kernel mapped lowmem pointer.

> The right thing to do would be converting to nobootmem (ie. memblock)
> and use the memblock interface.  Have no idea at all whether that
> would be a realistic short-term solution for arm.
>

I must plead ignorance and let wiser souls chime in on ARM architecture 
plans w.r.t. nobootmem.  As far as I can tell, the only thing that 
blocks us from using nobootmem at present is the need for sparsemem on 
some platforms.

-- 
Thanks
- Cyril

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
