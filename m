Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f51.google.com (mail-oa0-f51.google.com [209.85.219.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9EEDD6B018A
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 22:41:40 -0400 (EDT)
Received: by mail-oa0-f51.google.com with SMTP id j17so693213oag.38
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 19:41:40 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id sz9si38048644obc.33.2014.06.11.19.41.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 11 Jun 2014 19:41:40 -0700 (PDT)
Message-ID: <53991353.5040607@huawei.com>
Date: Thu, 12 Jun 2014 10:41:23 +0800
From: Zhang Zhen <zhenzhang.zhang@huawei.com>
MIME-Version: 1.0
Subject: Re: Proposal to realize hot-add *several sections one time*
References: <53981D81.5060708@huawei.com> <alpine.DEB.2.02.1406111503050.27885@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.02.1406111503050.27885@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: gregkh@linuxfoundation.org, laijs@cn.fujitsu.com, sjenning@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wang Nan <wangnan0@huawei.com>

On 2014/6/12 6:08, David Rientjes wrote:
> On Wed, 11 Jun 2014, Zhang Zhen wrote:
> 
>> Hi,
>>
>> Now we can hot-add memory by
>>
>> % echo start_address_of_new_memory > /sys/devices/system/memory/probe
>>
>> Then, [start_address_of_new_memory, start_address_of_new_memory +
>> memory_block_size] memory range is hot-added.
>>
>> But we can only hot-add *one section one time* by this way.
>> Whether we can add an argument on behalf of the count of the sections to add ?
>> So we can can hot-add *several sections one time*. Just like:
>>
> 
> Not necessarily true, it depends on sections_per_block.  Don't believe 
> Documentation/memory-hotplug.txt that suggests this is only for powerpc, 
> x86 and sh allow this interface as well.
> 
>> % echo start_address_of_new_memory count_of_sections > /sys/devices/system/memory/probe
>>
>> Then, [start_address_of_new_memory, start_address_of_new_memory +
>> count_of_sections * memory_block_size] memory range is hot-added.
>>
>> If this proposal is reasonable, i will send a patch to realize it.
>>
> 
> The problem is knowing how much memory is being onlined so that you can 
> definitively determine what count_of_sections should be.  The number of 
> pages per memory section depends on PAGE_SIZE and SECTION_SIZE_BITS which 
> differ depending on the architectures that support this interface.  So if 
> you support count_of_sections, it would return errno even though you have 
> onlined some sections.
> 
Hum, sorry.
My expression is not right. The count of sections one time hot-added
depends on sections_per_block.

Now we are porting the memory-hotplug to arm.
But we can only hot-add *fixed number of sections one time* on particular architecture.

Whether we can add an argument on behalf of the count of the blocks to add ?

% echo start_address_of_new_memory count_of_blocks > /sys/devices/system/memory/probe

Then, [start_address_of_new_memory, start_address_of_new_memory + count_of_blocks * memory_block_size]
memory range is hot-added.

So user don't need execute several times of echo when they want to hot add multi-block size memory.

Any comments are welcome.

Best regards!
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
