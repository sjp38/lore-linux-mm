Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id F321C6B0561
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 15:36:46 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id p206-v6so17192851itc.0
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 12:36:46 -0800 (PST)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id y7-v6si1352219itb.95.2018.11.07.12.36.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Nov 2018 12:36:45 -0800 (PST)
References: <20181107173859.24096-1-logang@deltatee.com>
 <20181107173859.24096-3-logang@deltatee.com>
 <20181107121207.62cb37cf58484b7cc80a8fd8@linux-foundation.org>
 <724be9bb-59b6-33f3-7b59-3ca644d59bf7@deltatee.com>
 <alpine.DEB.2.21.1811072125280.1666@nanos.tec.linutronix.de>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <b1cc442e-7314-4a8e-3eec-9adc200d7582@deltatee.com>
Date: Wed, 7 Nov 2018 13:36:34 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1811072125280.1666@nanos.tec.linutronix.de>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH 2/2] mm/sparse: add common helper to mark all memblocks
 present
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-riscv@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, Stephen Bates <sbates@raithlin.com>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <aou@eecs.berkeley.edu>, Christoph Hellwig <hch@lst.de>, Arnd Bergmann <arnd@arndb.de>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Oscar Salvador <osalvador@suse.de>



On 2018-11-07 1:26 p.m., Thomas Gleixner wrote:
> Logan,
> 
> On Wed, 7 Nov 2018, Logan Gunthorpe wrote:
>> On 2018-11-07 1:12 p.m., Andrew Morton wrote:
>>>> +void __init memblocks_present(void)
>>>> +{
>>>> +	struct memblock_region *reg;
>>>> +
>>>> +	for_each_memblock(memory, reg) {
>>>> +		memory_present(memblock_get_region_node(reg),
>>>> +			       memblock_region_memory_base_pfn(reg),
>>>> +			       memblock_region_memory_end_pfn(reg));
>>>> +	}
>>>> +}
>>>> +
>>>
>>> I don't like the name much.  To me, memblocks_present means "are
>>> memblocks present" whereas this actually means "memblocks are present".
>>> But whatever.  A little covering comment which describes what this
>>> does and why it does it would be nice.
>>
>> The same argument can be made about the existing memory_present()
>> function and I think it's worth keeping the naming consistent. I'll add
>> a comment and resend shortly.
> 
> Actually if both names suck, then there also is the option to rename both
> instead of adding a comment to explain the suckage.

Ok, well, I wasn't expecting to take on a big rename like that as it
would create a patch touching a bunch of arches and mm files... But if
we can come to some agreement on a better name and someone is willing to
take that patch without significant delay then I'd be happy to create
the patch and add it to the start of my series.

Some ideas for new names:

mark_memory_present() / mark_memblocks_present()
set_memory_present() / set_memblocks_present()
memory_register() / memblocks_register()
register_memory() / register_memblocks()

Logan
