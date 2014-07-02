Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 928B16B0031
	for <linux-mm@kvack.org>; Wed,  2 Jul 2014 02:48:53 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id et14so12060126pad.27
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 23:48:53 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id aw13si29383027pac.24.2014.07.01.23.48.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 01 Jul 2014 23:48:52 -0700 (PDT)
Message-ID: <53B3AB3B.1050809@huawei.com>
Date: Wed, 2 Jul 2014 14:48:27 +0800
From: Zhang Zhen <zhenzhang.zhang@huawei.com>
MIME-Version: 1.0
Subject: Re: How to boot up an ARM board enabled CONFIG_SPARSEMEM
References: <53B26229.5030504@huawei.com> <53B26364.1040606@huawei.com> <CAE9FiQWpPOELEAOZxxZafpkYqYPurL_Fx_zJsS4XM+DmFCYbxg@mail.gmail.com>
In-Reply-To: <CAE9FiQWpPOELEAOZxxZafpkYqYPurL_Fx_zJsS4XM+DmFCYbxg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Linux MM <linux-mm@kvack.org>, wangnan0@huawei.com

On 2014/7/2 2:45, Yinghai Lu wrote:
> On Tue, Jul 1, 2014 at 12:29 AM, Zhang Zhen <zhenzhang.zhang@huawei.com> wrote:
>> Hi,
>>
>> Recently We are testing stable kernel 3.10 on an ARM board.
>> It failed to boot if we enabled CONFIG_SPARSEMEM config.
> 
> Arm support 2 sockets and numa now?
> 
ARM doesn't support numa until now. We have added memory hotplug feature on ARM arch.
So we need to enable CONFIG_SPARSEMEM.

>> 1. In mem_init() and show_mem() compare pfn instead of page just like the patch in attachement.
>> 2. Enable CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER when enabled CONFIG_SPARSEMEM.
>>
>> QUESTION:
>>
>> I want to know why CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER depends on x86_64 ?
> 
> That make memory allocation have less memory hole, from old bootmem bitmap
> allocation stage.
> 
> Maybe we don't need that anymore as we have memblock allocation that is more
> smarter with alignment handling.
> 
> Also allocating big size and use them block by block, could save some time on
> searching on allocation function when memblock have lots of entries on
> memory/reserved arrays.
> 
> Thanks
> 
> Yinghai
> 
Hi, Yinghai

Have you seen my patch ?
If we enabled CONFIG_SPARSEMEM here in the patch need to enable CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER to
guarantee the pages of different sections are continuous.

So in my opinion, CONFIG_SPARSEMEM_ALLOC_MEM_MAP_TOGETHER doesn't need to depend on x86_64, which helps futher
coding.

If i'm wrong, please let me know !

Thanks for your comments!

> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
